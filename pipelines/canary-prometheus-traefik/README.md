## End-to-end prometheus canary deployment pipelins

### Learnings from Kayenta
* WATCH your promql.  Your group by should result in a result where BOTH your baseline AND control are returned in the same query.  Example of a bad query that will lead to failures:
```
query: "max(http_server_requests_seconds_max{app="demo-web-app-baseline", kubernetes_namespace="prod"}) by(kubernetes_pod_name, uri)"
```
Since the filter won't return both canary and baseline, the analysis will fail with "nodata" and and "NaN" for metrics in your canary. 

