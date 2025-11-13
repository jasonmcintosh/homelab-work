## Moving to clickhouse!

WHY?  Because 3 different systems for observability data (at least) is impossible to maintain effectively for an EVENT or DATA based approach.  E.g. Prometheus for metrics only with a different syntax than logs than for traces is impossible
to effectively operate.  Further, arbitrary, wide data just doesn't WORK with this kind of a design.

## References
For a more... production based OSS approach LONG TERM if this works I'll move here, but for POC this repo works

https://docs.altinity.com/altinitykubernetesoperator/kubernetesquickstartguide/quickcluster/
