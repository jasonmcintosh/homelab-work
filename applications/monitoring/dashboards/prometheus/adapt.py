"""Adapt uneeq-oss/spinnaker-mixin Grafana dashboards (rendered JSON) to this lab's Prometheus.

The mixin assumes the Armory observability plugin's series. This lab's Spinnaker sends Micrometer
metrics over OTLP -> otel-gateway -> prometheus remote-write, which differ in a few ways:
  * no `spinSvc` label; the service is the scrape `job` (e.g. orca-jasonmcintosh)
  * no `container` label on app series; cAdvisor series only carry `pod` (spin-<svc>-<hash>)
  * `controller_invocations_total` only holds Spinnaker's percentile gauges (statistic="percentile");
    request counts live in `controller_invocations_seconds_count`
"""
import json,re,sys,glob,os
def fix(e):
    e=re.sub(r'\bspinSvc\b(?=\s*(?:=|!=|=~|!~|,|\)|}))','job',e)
    e=e.replace('controller_invocations_total','controller_invocations_seconds_count')
    # cAdvisor series: container label is absent, match the pod instead
    e=re.sub(r'(container_[a-z_]+\{)([^}]*)\}',lambda m:m.group(1)+re.sub(r'container(=~?)"\$job"|container(=~?)"([^"]*)"',lambda k:'pod=~"spin-%s.*"'%(k.group(3) or '$spinSvc').replace('.*',''),m.group(2))+'}',e)
    # app series: service is identified by job
    e=re.sub(r'\bcontainer="([a-z0-9]+)"',r'job=~"\1.*"',e)
    return e
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
