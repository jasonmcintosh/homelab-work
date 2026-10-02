# Spinnaker Grafana dashboards (Prometheus)

Rendered from [uneeq-oss/spinnaker-mixin](https://github.com/uneeq-oss/spinnaker-mixin) and adapted
to this lab's metrics by `adapt.py`. Deployed to Grafana by `terraform/main.tf`
(`grafana_dashboard.spinnaker`, one per file here, in the "Spinnaker" folder).

The mixin assumes the Armory observability plugin's series. This lab's Spinnaker sends Micrometer
metrics over OTLP, so `adapt.py` rewrites the queries:

- `spinSvc` label -> `job` (e.g. `orca-jasonmcintosh`); there is no `spinSvc` label
- `controller_invocations_total` -> `controller_invocations_seconds_count`; the `_total` series only
  hold Spinnaker's percentile gauges (`statistic="percentile"`), not request counts
- `container="<svc>"` on app series -> `job=~"<svc>.*"`; on cAdvisor series -> `pod=~"spin-<svc>.*"`

Regenerate (needs go-jsonnet and a grafonnet-lib checkout under `vendor/`):

    jsonnet -J vendor -J dashboards dashboards/<name>.jsonnet > out/<name>.json
    python3 adapt.py out dashboards/prometheus-spinnaker

Included but without data in this lab, kept so others can use them once they have the data:
`deck` (Deck is a static Apache server and exports no metrics; these panels expect HTTP request
metrics from an instrumented web server), `spinnaker-aws-platform` and `spinnaker-google-platform`
(no AWS or Google cloud-provider traffic here). Their queries are the mixin's, only relabelled by
`adapt.py`, and have not been checked against real series.

Known gaps: the kubelet scrape only returns cAdvisor series for some pods, so the CPU/memory/network
panels are empty for services whose pods aren't scraped; panels for 5xx/429 stay empty until those occur.
