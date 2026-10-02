#!/usr/bin/env python3
"""Translate the PromQL Spinnaker dashboards in ../prometheus into Grafana dashboards that query
the ClickHouse OTel tables (otel.otel_metrics_{gauge,sum,histogram}) with the grafana-clickhouse
datasource.

    python3 translate.py ../prometheus .          # writes <name>.json.tpl (Terraform templatefile, ${ch_uid})

Only the PromQL subset the mixin uses is supported: selectors, rate(), *_over_time(), sum/avg/min/
max/count [by (...)], binary arithmetic, label_replace(). Anything else (or a metric with no
ClickHouse equivalent) turns the panel into a text panel saying why, instead of a broken query.

Semantics: counters/histogram counts are cumulative in ClickHouse (AggregationTemporality 2), so
rate() is the per-series delta between consecutive $__interval_s buckets divided by the elapsed
seconds. Panels carry a 1m minimum interval because the Java agents export every 60s.
"""
import json, re, sys, os, glob
import promql_parser as pq

HERE = os.path.dirname(os.path.abspath(__file__))
DS = {"type": "grafana-clickhouse-datasource", "uid": "${ch_uid}"}
T = {"gauge": "otel.otel_metrics_gauge", "sum": "otel.otel_metrics_sum", "histogram": "otel.otel_metrics_histogram"}
UNIT = {"s": "_seconds", "By": "_bytes", "bytes": "_bytes", "ms": "_milliseconds"}
def unit_suffix(u):
    return UNIT.get(u, "" if u in ("", "1") else "_" + re.sub(r"[^a-z0-9]", "_", u.lower()))

class Unsupported(Exception): pass

# ---- metric name mapping: Prometheus name -> (table, ClickHouse MetricName, value column) ----
def build_map():
    m = {}
    for line in open(os.path.join(HERE, "metrics.tsv")):
        t, name, unit, _ = line.rstrip("\n").split("\t")
        us = unit_suffix(unit)
        base = re.sub(r"[^a-zA-Z0-9_]", "_", name) + us
        if t == "gauge" and name.endswith(".max") and us:   # Prometheus also spells these <name>_<unit>_max
            m.setdefault(re.sub(r"[^a-zA-Z0-9_]", "_", name[:-4]) + us + "_max", ("gauge", name, "Value"))
        if t == "gauge":
            m.setdefault(base, ("gauge", name, "Value"))
        elif t == "sum":
            m.setdefault(base + "_total", ("sum", name, "Value"))
            m.setdefault(base, ("sum", name, "Value"))
        else:
            m.setdefault(base + "_count", ("histogram", name, "Count"))
            m.setdefault(base + "_sum", ("histogram", name, "Sum"))
    return m
MAP = build_map()
UNMAPPED = []   # (prom metric) with no known ClickHouse metric; guessed

def resolve(name):
    if name in MAP: return MAP[name]
    if name.startswith("container_"):   # kubelet cAdvisor, scraped by otel-gateway (prometheus/cadvisor); names kept verbatim
        return ("sum", name, "Value") if name.endswith("_total") else ("gauge", name, "Value")
    if name.startswith(("kube_", "up")) and name != "up_time":
        raise Unsupported(f"`{name}` is a cAdvisor/kube-state/scrape series with no ClickHouse equivalent")
    # unknown (e.g. AWS/Google-only metrics not emitted here): invert the Prometheus naming best-effort
    UNMAPPED.append(name)
    t, col = ("histogram", "Count") if name.endswith("_count") else ("histogram", "Sum") if name.endswith("_sum") else ("sum", "Value") if name.endswith("_total") else ("gauge", "Value")
    base = re.sub(r"_(count|sum|total)$", "", name)
    base = re.sub(r"_(seconds|bytes|milliseconds)$", "", base)
    return (t, base.replace("__", ".").replace(":", ".").replace("_", "."), col)

# ---- label -> column expression ----
def lab(name):
    if name == "job": return "ServiceName"
    if name == "instance": return "ResourceAttributes['service.instance.id']"
    return f"Attributes['{name}']"
def q(s): return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"
def bt(n): return "`" + n + "`"

# ---- compiled relation: SQL with columns time, <labels...>, value ----
class Rel:
    def __init__(self, sql, labels, leaf=None): self.sql, self.labels, self.leaf = sql, list(labels), leaf

VAR = re.compile(r"^\$\{?(\w+)\}?$")
def matcher_sql(m):
    col, op, val = lab(m.name), str(m.op), m.value
    v = VAR.match(val) if val.startswith("$") else None
    if v and v.group(1) not in ("__all",):
        pos = op in ("=", "=~", "MatchOp.Equal", "MatchOp.Re")
        return f"{col} {'IN' if pos else 'NOT IN'} (${v.group(1)})"
    emb = re.fullmatch(r"(.*?)\$(\w+)(.*)", val, re.S) if "$" in val else None
    if emb and emb.group(2) != "__all":
        pre, var, post = emb.groups()
        cond = f"arrayExists(x -> match({col}, concat({q('^(?:' + pre)}, x, {q(post + ')$')})), [${var}])"
        return ("NOT " if "Not" in op or op == "!~" else "") + cond
    if "Equal" in op or op == "=" or op == "!=":
        return f"{col} {'!=' if 'Not' in op or op == '!=' else '='} {q(val)}"
    return f"{'NOT ' if 'Not' in op or op == '!~' else ''}match({col}, {q('^(?:' + val + ')$')})"

def leaf(vs, need, fn=None, rng=None):
    t, mname, field = resolve(vs.name)
    where = [f"MetricName = {q(mname)}", "$__timeFilter(TimeUnix)"] + [matcher_sql(m) for m in vs.matchers.matchers]
    labs = sorted(need)
    sel = ", ".join(f"{lab(l)} AS {bt(l)}" for l in labs)
    agg = {"max_over_time": "max", "min_over_time": "min", "avg_over_time": "avg"}.get(fn)
    if agg is None:
        agg = "max" if fn == "rate" else "argMax"
    valexpr = f"argMax({field}, TimeUnix)" if agg == "argMax" else f"{agg}({field})"
    cols = f"toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series" + (", " + sel if sel else "") + f", {valexpr} AS value"
    grp = "time, series" + ("".join(f", {bt(l)}" for l in labs))
    return Rel(f"SELECT {cols} FROM {T[t]} WHERE {' AND '.join(where)} GROUP BY {grp}", labs, leaf=fn)

def to_rate(r):
    lc = "".join(f", {bt(l)}" for l in r.labels)
    return Rel(
        "SELECT time" + lc + ", d / dt AS value FROM (SELECT time" + lc +
        ", greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d,"
        " dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt"
        f" FROM ({r.sql})) WHERE d IS NOT NULL AND dt > 0", r.labels)

def strip_series(r):   # raw leaf used without rate/aggregation: keep series so rows stay distinct
    return r

def compile_(n, need):
    k = type(n).__name__
    if k == "ParenExpr": return compile_(n.expr, need)
    if k == "NumberLiteral": return n.val
    if k == "VectorSelector": return leaf(n, need)
    if k == "MatrixSelector": raise Unsupported("bare range vector")
    if k == "Call":
        f = n.func.name if hasattr(n.func, "name") else str(n.func)
        if f == "rate" or f == "increase" or f == "irate":
            sel = n.args[0]
            if type(sel).__name__ != "MatrixSelector": raise Unsupported(f)
            return to_rate(leaf(sel.vector_selector, need, "rate"))
        if f in ("max_over_time", "min_over_time", "avg_over_time"):
            sel = n.args[0]
            return leaf(sel.vector_selector, need, f)
        if f == "label_replace":
            src_need = set(need)
            dst, repl, srcl, rx = [a.val for a in n.args[1:5]]
            src_need.discard(dst); src_need.add(srcl)
            r = compile_(n.args[0], src_need)
            lc = [l for l in r.labels if l != dst]
            lcs = "".join(f", {bt(l)}" for l in lc)
            rx2 = '^(?:' + rx + ')$'
            rep = re.sub(r"\$(\d)", r"\\\1", repl)
            old = bt(dst) if dst in r.labels else "''"
            src = bt(srcl) if srcl in r.labels else "''"   # a missing label is "" in PromQL, so no match
            ser = ", series" if r.sql.startswith("SELECT time, series") else ""
            return Rel(f"SELECT time{ser}{lcs}, if(match({src}, {q(rx2)}), replaceRegexpOne({src}, {q(rx2)}, {q(rep)}), {old}) AS {bt(dst)}, value FROM ({r.sql})", lc + [dst])
        raise Unsupported(f"function {f}")
    if k == "AggregateExpr":
        op = str(n.op)
        fnm = {"sum": "sum", "avg": "avg", "max": "max", "min": "min", "count": "count"}.get(op)
        if not fnm: raise Unsupported(f"aggregation {op}")
        mod = n.modifier
        if mod is not None and "Without" in str(mod.type):
            by = None
        else:
            by = list(mod.labels) if mod is not None else []
        if by is None:
            # without(): group by every label the parents need (we cannot enumerate the rest)
            by = sorted(set(need) | {"pod"})   # cAdvisor: sum the per-interface series within each pod
        inner = compile_(n.expr, set(by))
        lc = "".join(f", {bt(l)}" for l in by)
        return Rel(f"SELECT time{lc}, {fnm}(value) AS value FROM ({inner.sql}) GROUP BY time{lc}", by)
    if k == "BinaryExpr":
        op = str(n.op)
        if op not in ("+", "-", "*", "/"): raise Unsupported(f"operator {op}")
        l, r = compile_(n.lhs, need), compile_(n.rhs, need)
        def num(x): return isinstance(x, (int, float))
        if num(l) and num(r): raise Unsupported("constant expression")
        if num(r): return Rel(f"SELECT time{''.join(', '+bt(x) for x in l.labels)}, value {op} {r} AS value FROM ({l.sql})", l.labels)
        if num(l): return Rel(f"SELECT time{''.join(', '+bt(x) for x in r.labels)}, {l} {op} value AS value FROM ({r.sql})", r.labels)
        common = [x for x in l.labels if x in r.labels]
        keys = ", ".join(["time"] + [bt(x) for x in common])
        outl = ", ".join(["time"] + [bt(x) for x in common])
        rhs = f"nullIf(b.value, 0)" if op == "/" else "b.value"
        # join the two sides on time + shared labels, collapsing duplicates per key first
        agg = lambda s: f"SELECT {keys}, sum(value) AS value FROM ({s}) GROUP BY {keys}"
        return Rel(f"SELECT {outl}, a.value {op} {rhs} AS value FROM ({agg(l.sql)}) AS a ALL INNER JOIN ({agg(r.sql)}) AS b USING ({keys})", common)
    raise Unsupported(k)

def parse_expr(e):
    e = re.sub(r"\$\{?__(rate_)?interval\}?", "5m", e)
    e = e.replace("$__range", "1h")
    return pq.parse(e)

def legend_labels(fmt): return set(re.findall(r"\{\{\s*(\w+)\s*\}\}", fmt or ""))

def target_sql(expr, legend):
    need = legend_labels(legend)
    rel = compile_(parse_expr(expr), need)
    labs = rel.labels
    if legend:
        parts = re.split(r"(\{\{\s*\w+\s*\}\})", legend)
        pieces = []
        for p in parts:
            m = re.match(r"\{\{\s*(\w+)\s*\}\}", p)
            if m: pieces.append(bt(m.group(1)) if m.group(1) in labs else "''")
            elif p: pieces.append(q(p))
        metric = "concat(" + ", ".join(pieces) + ")" if len(pieces) > 1 else (pieces[0] if pieces else "'value'")
    else:
        metric = "concat(" + ", ".join(q(l + "=") + ", " + bt(l) for l in labs[:1]) + ")" if labs else "'value'"
    return f"SELECT time, {metric} AS metric, value FROM ({rel.sql}) ORDER BY time"

# ---- template variables ----
def var_query(v, svc):
    qy = v.get("query", "")
    m = re.match(r'label_values\(([\w:]+)(?:\{([^}]*)\})?,\s*(\w+)\)', qy)
    if not m and re.fullmatch(r'[\w:]+', qy or ''):
        # the mixin's GcpRegion variable is just a metric name (a malformed query); intended label is region
        metric, matchers, label = qy, '', 'region'
    elif not m: return None
    else: metric, matchers, label = m.groups()
    matchers = matchers or ''
    if metric == "up":
        t, tbl, where = "gauge", T["gauge"], []
        mname = None
    else:
        t, mname, _ = resolve(metric); tbl = T[t]; where = [f"MetricName = {q(mname)}"]
    for mm in re.finditer(r'(\w+)(=~|!~|=|!=)"([^"]*)"', matchers):
        k, op, val = mm.groups()
        val = val.replace("$spinSvc", svc)
        vv = VAR.match(val)
        if vv: where.append(f"{lab(k)} IN (${vv.group(1)})")
        elif op in ("=~", "!~"):
            where.append(f"{'NOT ' if op == '!~' else ''}match({lab(k)}, {q('^(?:' + val + ')$')})")
        else: where.append(f"{lab(k)} {op} {q(val)}")
    where.append("TimeUnix > now() - INTERVAL 6 HOUR")
    return f"SELECT DISTINCT {lab(label)} FROM {tbl} WHERE {' AND '.join(where)} ORDER BY 1"

def convert_vars(d):
    out = []
    svc = next((v["query"] for v in d["templating"]["list"] if v["name"] == "spinSvc"), "")
    for v in d["templating"]["list"]:
        if v["type"] == "datasource": continue
        if v["type"] == "custom":
            out.append({k: v[k] for k in ("name", "label", "type", "query", "current", "options", "multi", "includeAll", "hide") if k in v}); continue
        sql = var_query(v, svc)
        if sql is None: continue
        out.append({"name": v["name"], "label": v.get("label") or v["name"], "type": "query", "datasource": DS,
                    "definition": sql, "query": {"rawSql": sql}, "refresh": 2, "multi": True, "includeAll": True,
                    "current": {"selected": True, "text": "All", "value": "$__all"}, "sort": 1, "hide": 0})
    return out

# ---- panels ----
def graph_to_ts(p, gid, x, y, w, h, err_log, dash):
    targets, notes = [], []
    for t in p.get("targets", []):
        try:
            targets.append({"refId": t["refId"], "datasource": DS, "format": 0, "queryType": "timeseries", "rawSql": target_sql(t["expr"], t.get("legendFormat"))})
        except Unsupported as ex:
            notes.append(f"{t['refId']}: {ex}")
        except Exception as ex:
            notes.append(f"{t['refId']}: could not translate ({type(ex).__name__}: {ex})")
    if not targets:
        err_log.append((dash, p.get("title"), notes))
        return {"id": gid, "type": "text", "title": p.get("title", ""), "gridPos": {"x": x, "y": y, "w": w, "h": h},
                "options": {"mode": "markdown", "content": "Not available from ClickHouse.\n\n" + "\n".join("- " + n for n in notes) + f"\n\nPrometheus original: `{(p.get('targets') or [{}])[0].get('expr','')}`"}}
    if notes: err_log.append((dash, p.get("title"), notes))
    ya = (p.get("yaxes") or [{}])[0]
    defaults = {"unit": ya.get("format", "short"), "custom": {"fillOpacity": int(p.get("fill", 1)) * 10, "lineWidth": p.get("linewidth", 1),
                "stacking": {"mode": "normal" if p.get("stack") else "none"}, "spanNulls": False}}
    if ya.get("min") is not None: defaults["min"] = ya["min"]
    if ya.get("max") is not None: defaults["max"] = ya["max"]
    lg = p.get("legend", {})
    return {"id": gid, "type": "timeseries", "title": p.get("title", ""), "description": p.get("description", ""), "datasource": DS,
            "gridPos": {"x": x, "y": y, "w": w, "h": h}, "interval": "1m", "targets": targets,
            "fieldConfig": {"defaults": defaults, "overrides": []},
            "options": {"legend": {"showLegend": lg.get("show", True), "displayMode": "table" if lg.get("alignAsTable") else "list",
                        "placement": "right" if lg.get("rightSide") else "bottom",
                        "calcs": [c for c in ("max", "min", "avg", "current") if lg.get(c)]}, "tooltip": {"mode": "multi", "sort": "desc"}}}

def convert(d, err_log):
    name = d["title"]
    panels, gid, y = [], 1, 0
    for r in d.get("rows", []):
        if r.get("showTitle", True) and r.get("title"):
            panels.append({"id": gid, "type": "row", "title": r["title"], "collapsed": False, "gridPos": {"x": 0, "y": y, "w": 24, "h": 1}, "panels": []}); gid += 1; y += 1
        x, rowh = 0, 0
        for p in r.get("panels", []):
            w = max(1, min(24, int(p.get("span", 12)) * 2)); h = 8
            if x + w > 24: x, y, rowh = 0, y + rowh, 0
            if p["type"] == "text":
                panels.append({"id": gid, "type": "text", "title": p.get("title", ""), "gridPos": {"x": x, "y": y, "w": w, "h": h},
                               "options": {"mode": p.get("mode", "markdown"), "content": p.get("content", "")}})
            else:
                panels.append(graph_to_ts(p, gid, x, y, w, h, err_log, name))
            gid += 1; x += w; rowh = max(rowh, h)
        y += rowh
    return {"title": name + " (ClickHouse)", "uid": "ch-" + d["uid"], "schemaVersion": 39, "editable": True, "refresh": d.get("refresh", "1m"),
            "tags": sorted(set(d.get("tags", []) + ["clickhouse"])), "time": d.get("time", {"from": "now-1h", "to": "now"}),
            "links": d.get("links", []), "templating": {"list": convert_vars(d)}, "panels": panels}

if __name__ == "__main__":
    src, dst = sys.argv[1:3]
    err = []
    for f in sorted(glob.glob(os.path.join(src, "*.json"))):
        d = json.load(open(f))
        out = convert(d, err)
        json.dump(out, open(os.path.join(dst, os.path.basename(f)[:-5] + ".json.tpl"), "w"), indent=2); open(os.path.join(dst, os.path.basename(f)[:-5] + ".json.tpl"), "a").write("\n")
        print(os.path.basename(f), len(out["panels"]), "panels")
    print("\nPANELS NOT (FULLY) TRANSLATED:", len(err))
    for dash, title, notes in err: print(f"  [{dash}] {title}: {'; '.join(notes)[:150]}")
    print("\nMETRICS GUESSED (no ClickHouse series found):", sorted(set(UNMAPPED)))
