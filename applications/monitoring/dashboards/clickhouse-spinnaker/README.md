# Spinnaker Grafana dashboards (ClickHouse)

ClickHouse equivalents of `../prometheus/*.json`, so Spinnaker observability can move off Prometheus.
Generated, not hand-written:

    python3 -m venv .venv && .venv/bin/pip install promql-parser
    .venv/bin/python translate.py ../prometheus .

`translate.py` parses each PromQL query and compiles it to SQL over `otel.otel_metrics_{gauge,sum,
histogram}` (the tables the otel-gateway's clickhouse exporter fills). `metrics.tsv` is the list of
(table, MetricName, unit) the Spinnaker services emit, used to map Prometheus names such as
`controller_invocations_seconds_count` back to `controller.invocations` / `Count`.

Semantics worth knowing:

- Counters and histogram counts are cumulative in ClickHouse, so `rate()` is the per-series delta
  between consecutive `$__interval_s` buckets over the elapsed seconds. Panels have a 1m minimum interval
  because the Java agents export every 60s.
- `job` -> `ServiceName`, `instance` -> `ResourceAttributes['service.instance.id']`, any other label ->
  `Attributes['<label>']`.
- Template variables are re-created as ClickHouse queries; `=~"$var"` becomes `IN ($var)`.
- Supported PromQL: selectors, `rate`, `increase`, `*_over_time`, `sum/avg/min/max/count [by]`,
  `+ - * /`, `label_replace`. Anything else becomes a text panel that says why.

Known gaps:

- cAdvisor and kube-state series (`container_*`, `kube_*`: CPU throttling, network, limits) have no
  ClickHouse equivalent, so those panels are text panels or partial. CPU and memory use the OTel
  `kubeletstats` names (`k8s.pod.cpu.usage`, `k8s.pod.memory.working_set`), which are only populated once
  a kubeletstats receiver is added to a collector.
- `deck`, AWS and Google platform dashboards use metric names this lab never emits, so their ClickHouse
  metric names are inferred from the Prometheus ones and unverified.
