## Moving to clickhouse!

WHY?  Because 3 different systems for observability data (at least) is impossible to maintain effectively for an EVENT or DATA based approach.  E.g. Prometheus for metrics only with a different syntax than logs than for traces is impossible
to effectively operate.  Further, arbitrary, wide data just doesn't WORK with this kind of a design.

## References
For a more... production based OSS approach LONG TERM if this works I'll move here, but for POC this repo works

https://docs.altinity.com/altinitykubernetesoperator/kubernetesquickstartguide/quickcluster/

## Architecture (2026-09)

```
                         ilo-prometheus (scrape target)
                                 |
ilo-collector  ---\              |  otlp
k8s-events collector ---\        v
(collector-k8s-events.yml) ----> otel-gateway --clickhouse--> clickhouse --> grafana
spinnaker's opentelemetrycollector ---/    |                       |            |
(applications/spinnaker/collector.yml)     |--prometheusremotewrite--> prometheus  \--> clickstack (HyperDX)
                                            |--prometheus receiver (spring-boot-apps scrape)
```

`otel-gateway` (`collector-gateway.yaml`) is the **only** place forwarding credentials/
endpoints live now. `ilo-collector`, the k8s-events collector, and spinnaker's
`opentelemetrycollector` each keep their own receiver-side logic (ilo scraping, k8s object
watching, edge trace sampling) but forward everything to the gateway over OTLP - changing
where data goes is a one-file change. The gateway also directly scrapes the same
`spring-boot-apps` Kubernetes pods `prometheus.yaml` scrapes, so app metrics (including
Spinnaker's clouddriver) land in ClickHouse too, not just Prometheus.

### ClickHouse: tuning, retention, storage

`clickhouse.yaml` was tuned for a lab-scale single-node deployment: background merge/insert
thread pools sized to the container's CPU limit (the ClickHouse defaults assume much bigger
boxes and were likely contention, not capacity, causing the reported slowness), server-wide
async-insert settings to coalesce the many small OTel inserts into fewer/larger parts, and
Guaranteed QoS resource sizing. Retention is two-layered: every table gets a `ttl: 72h`
(configured on the `clickhouse` exporter in `collector-gateway.yaml`) so old partitions drop
automatically and cheaply, plus an hourly `clickhouse-retention-guard` CronJob as a
space-based backstop (ClickHouse has no `--storage.tsdb.retention.size` equivalent).

Storage stays on `rook-ceph-block` for now (explicitly pinned - the cluster's actual default
StorageClass is `nfs-csi-default`, a poor fit for ClickHouse's MergeTree I/O pattern). A
ready-to-flip `emptyDir` alternative is documented inline in `clickhouse.yaml` if the tuning
above isn't enough and full ephemeral-local-storage becomes worth the "wiped on every pod
restart" tradeoff - this uses native kubelet ephemeral-storage support already present in
microk8s, no addon required.

### ClickStack (HyperDX) evaluation

`clickstack.yaml` deploys HyperDX's UI/app server (+ its own small MongoDB for app state -
dashboards/alerts/saved searches, not telemetry) pointed at the *existing* ClickHouse -
deliberately not ClickStack's bundled OTel collector, since `otel-gateway` already covers
that. It's reachable at `https://clickstack.mcintosh.farm`, alongside (not replacing)
Grafana at `https://grafana.mcintosh.farm`, for a side-by-side evaluation.

### Dashboards as code

`terraform/` manages both Grafana and ClickStack/HyperDX dashboards from the same
hand-ported panel definitions (PromQL doesn't mechanically translate to ClickHouse SQL or
ClickStack's metric-builder format, so each panel was ported by hand, not generated):

- **Grafana**: `grafana_dashboard` resources (official `grafana/grafana` provider) load
  `dashboards/clickhouse/*.json.tpl` - raw SQL panels against the `grafana-clickhouse-
  datasource` plugin (added to `grafana.yaml` via `GF_INSTALL_PLUGINS`).
- **ClickStack**: `clickstack.tf` manages `clickhouse_clickstack_dashboard` resources
  directly in HCL, using the same panels expressed as ClickStack's metric-builder tiles.
  This uses the official `ClickHouse/clickhouse` Terraform provider's self-hosted-ClickStack
  support (`clickstack_endpoint` + `clickstack_api_key`, no ClickHouse Cloud account
  involved) - there's no need for a hand-rolled API script.

Three dashboards are ported: Spinnaker/clouddriver (`controller_invocations_*`, JVM metrics),
iLO (`ilo_*` gauges from MauveSoftware/ilo_exporter), and a generic in-house Spring Boot
dashboard (standard Actuator metrics, works for any pod labeled `type=spring-boot-app`, not
just clouddriver). These are a representative starting subset, not a full 1:1 port of every
panel in the original `dashboards/clouddriver.json` (60+ panels) - extend using the same
sum/count-delta-join pattern (see the panel `description` fields) as needed.

**One-time manual bootstrap** before `terraform apply` (same pattern as the kubeconfig/
oauth2 secrets in `applications/spinnaker/README.md`):

```
kubectl create secret generic grafana-api-token -n monitoring --from-literal token='<Grafana admin-role service-account token>'
kubectl create secret generic clickstack-api-key -n monitoring --from-literal token='<HyperDX personal API access key, from the HyperDX UI after first login>'
```
