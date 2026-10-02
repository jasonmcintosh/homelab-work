"""Adapt uneeq-oss/spinnaker-mixin Grafana dashboards (rendered JSON) to this lab's Prometheus.

The mixin assumes the Armory observability plugin's series. This lab's Spinnaker sends Micrometer
metrics over OTLP -> otel-gateway -> prometheus remote-write, which differ in a few ways:
  * no `spinSvc` label; the service is the scrape `job` (e.g. orca-jasonmcintosh)
  * no `container` label on app series (the service is the scrape `job`)
  * `controller_invocations_total` only holds Spinnaker's percentile gauges (statistic="percentile");
    request counts live in `controller_invocations_seconds_count`
"""
import json,re,sys,glob,os
SEL = re.compile(r'([A-Za-z_:][\w:]*)\{([^}]*)\}')
def fix_selector(m):
    name, body = m.group(1), m.group(2)
    if name.startswith(('container_', 'kube_')):
        # cAdvisor/kube-state series do carry a container label (the Spinnaker container is named
        # after the service); only the network panels' pod regex lacks the "spin-" pod prefix.
        body = body.replace('pod=~"$spinSvc', 'pod=~"spin-$spinSvc')
    else:
        # app series: service is identified by job, not spinSvc/container
        body = re.sub(r'\bcontainer="([a-z0-9]+)"', r'job=~"\1.*"', body)
    return name + '{' + body + '}'
def fix(e):
    e=e.replace('controller_invocations_total','controller_invocations_seconds_count')
    e=SEL.sub(fix_selector,e)
    # remaining spinSvc label uses (grouping clauses etc.)
    return re.sub(r'\bspinSvc\b(?=\s*(?:=|!=|=~|!~|,|\)|}))','job',e)
def walk(o):
    if isinstance(o,dict):
        for k,v in o.items():
            if k=='expr' and isinstance(v,str): o[k]=fix(v)
            else: walk(v)
    elif isinstance(o,list):
        for v in o: walk(v)
if __name__=='__main__':
    src,dst=sys.argv[1:3]; os.makedirs(dst,exist_ok=True)
    for f in glob.glob(src+'/*.json'):
        d=json.load(open(f)); walk(d)
        json.dump(d,open(os.path.join(dst,os.path.basename(f)),'w'),indent=2,sort_keys=True); open(os.path.join(dst,os.path.basename(f)),'a').write('\n')
