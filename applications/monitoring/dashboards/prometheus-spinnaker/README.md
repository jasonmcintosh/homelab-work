# Spinnaker Grafana dashboards (Prometheus)

Spinnaker service dashboards (clouddriver, orca, gate, front50, fiat, echo, igor, rosco, plus the cross-service
key-metrics / minimalist / application-details / Kubernetes-platform views). They are maintained here, as plain
Grafana JSON: edit them in Grafana and export, or edit the files. `terraform/main.tf` deploys each one
(`grafana_dashboard.spinnaker`, folder "Spinnaker"). The ClickHouse versions in `../clickhouse-spinnaker` are
generated from these by `translate.py`, so regenerate those after changing a dashboard here.

## Provenance

Started from the dashboards in [uneeq-oss/spinnaker-mixin](https://github.com/uneeq-oss/spinnaker-mixin)
(Apache License 2.0), then modified for the metrics Spinnaker actually exports over OTLP (below). Many thanks to
the uneeq-oss authors and contributors: their dashboards are the foundation of this set. This repo is Apache 2.0
as well; keep this attribution if the dashboards are redistributed.

## What matters for these metrics (OTLP -> otel-gateway -> Prometheus remote-write)

- **Service label:** the service is `job` (e.g. `orca-jasonmcintosh`); there is no `spinSvc` label.
- **Template variables must not use `up`:** `up` only exists for jobs Prometheus scrapes itself, so a
  `label_values(up{...})` variable is empty for pushed metrics and every panel shows no data. The `job` and
  `Instance` variables use `jvm_memory_used_bytes`.
- **Datasource scrape interval must be 60s:** services export every 60s, but Grafana assumes 15s, which makes
  `$__rate_interval` 1m, and `rate()` over a 1m window of 60s-spaced samples is empty. `terraform/main.tf` sets
  `timeInterval = "60s"` on the Prometheus datasource (4m rate window). Do the same on any other Grafana.
- **Request counts** come from `controller_invocations_seconds_count`; `controller_invocations_total` only holds
  Spinnaker's percentile gauges (`statistic="percentile"`).
- **Metric spellings for OTLP series:** `jvm_gc_pause_max_seconds`, `jvm_threads_live`,
  `queue_message_lag_max_seconds` (the `_seconds_max` / `_threads` spellings only exist for scraped apps).
- **Container metrics** (`container_*`) carry a `container` label equal to the service name, and need cAdvisor
  coverage of every node (see `prometheus.yaml`).

## Dashboards with no data in this lab

`deck` (a static Apache server; these panels expect HTTP metrics from an instrumented web server),
`spinnaker-aws-platform` and `spinnaker-google-platform` (no AWS or Google cloud-provider traffic). Their queries
are unverified against real series; they are kept for anyone who has those metrics.

Panels for 5xx/429, bakes, dead queue messages and similar stay empty until the event happens, and the
`kube_pod_container_resource_*` lines need kube-state-metrics, which this lab doesn't run.
