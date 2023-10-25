## End-to-end prometheus canary deployment pipelins

### Learnings from Kayenta
* WATCH your promql.  Example of a bad query that will lead to failures:
```
query: "max(http_server_requests_seconds_max{app="demo-web-app-baseline", kubernetes_namespace="prod"}) by(kubernetes_pod_name, uri)"
```

I've seen some rather odd failures, and it's ALWAYS good to test using a "retrospective" analysis before making changes.
