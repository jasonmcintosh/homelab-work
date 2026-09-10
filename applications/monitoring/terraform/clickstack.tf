# Self-hosted ClickStack authenticates separately from the (unused, ClickHouse-Cloud-only)
# default provider block in main.tf - clickstack_endpoint + clickstack_api_key, no Cloud
# account involved. See https://registry.terraform.io/providers/ClickHouse/clickhouse/latest/docs
# ("ClickStack (beta)" section) - these resources are marked beta upstream and may change.
# Uses the public ingress host, not the in-cluster Service, since `terraform apply` may run
# from a workstation outside the cluster network rather than from an in-cluster pod.
provider "clickhouse" {
  alias                = "clickstack"
  clickstack_endpoint  = "https://clickstack.mcintosh.farm"
  clickstack_api_key   = data.kubernetes_secret.clickstack_token.data["token"]
}

data "kubernetes_secret" "clickstack_token" {
  metadata {
    namespace = "monitoring"
    name      = "clickstack-api-key"
  }
}

# Points ClickStack at the same ClickHouse used by Grafana and otel-gateway.
resource "clickhouse_clickstack_connection" "main" {
  provider = clickhouse.clickstack
  name     = "monitoring ClickHouse"
  host     = "https://clickhouse.mcintosh.farm"
  username = "clickhouse"
  password = "changeme"
}

# One metric source covering all three metric tables the clickhouseexporter creates
# (see collector-gateway.yaml). All 3 dashboards below are metrics-only, so no log/trace
# source is needed yet.
resource "clickhouse_clickstack_source" "metrics" {
  provider      = clickhouse.clickstack
  name          = "otel metrics"
  kind          = "metric"
  connection_id = clickhouse_clickstack_connection.main.id

  from = {
    database_name = "otel"
  }

  timestamp_value_expression     = "TimeUnix"
  resource_attributes_expression = "ResourceAttributes"

  metric_tables = {
    gauge     = "otel_metrics_gauge"
    sum       = "otel_metrics_sum"
    histogram = "otel_metrics_histogram"
  }
}

# Same 5 panels as dashboards/clickhouse/clouddriver.json.tpl, expressed as ClickStack's
# metric-builder tiles instead of raw SQL.
#
# Grounded against real data (queried via the ClickHouse HTTP API with the connection's own
# username/password), not assumed Prometheus-exporter names, after those assumptions turned
# out wrong in three ways:
#
# 1. ServiceName is "clouddriver-jasonmcintosh", not "clouddriver" - Spinnaker's own
#    hostname-suffixed instance name, not a clean service name. `where` filters below use
#    the real value.
# 2. Clouddriver exports metrics natively via OTLP (Micrometer's OTLP registry), which keeps
#    Micrometer's dotted names as-is (e.g. "controller.invocations", "jvm.memory.used") -
#    unlike the Prometheus-scraped services (in-house Spring Boot apps), which go through
#    the OTel Collector's prometheus receiver and get Prometheus-convention
#    underscore+unit names (e.g. "jvm_memory_used_bytes"). The two pipelines share this one
#    ClickStack source/table set, so metric names must be checked per-service, not assumed
#    from one convention. "controller_invocations_total" /
#    "controller_invocations_seconds_{sum,count}" / "jvm_memory_used_bytes" /
#    "jvm_gc_pause_seconds_{sum,count}" don't exist for clouddriver; the real names are used
#    below.
# 3. Micrometer's Timer meters (controller.invocations, jvm.gc.pause) land in the HISTOGRAM
#    table with real Count/Sum columns (verified: sum(Count)=10,273,136,
#    sum(Sum)=839,672s for controller.invocations at the time of writing) - the
#    otel_metrics_sum rows under the same name are separately-reported percentile
#    gauges (Attributes['statistic']='percentile'), not invocation counts. ClickStack's
#    histogram select only supports aggFn "count" (rate of the cumulative Count field,
#    delta-computed automatically - see translateHistogramCount in
#    hyperdxio/hyperdx's packages/common-utils/src/core/histogram.ts) or "quantile"
#    (needs a "level"); there's no sum/count-ratio "avg" option, so the former "avg
#    latency" tile below is a p50 quantile instead. The API's own validation requires
#    valueExpression on every non-"count" select regardless of metric type ("Value
#    expression is required for non-count aggregation functions"), even though
#    translateHistogram never actually reads it for histograms - so the quantile
#    selects below carry a placeholder "Value" to satisfy validation.
resource "clickhouse_clickstack_dashboard" "clouddriver" {
  provider = clickhouse.clickstack
  dashboard_json = jsonencode({
    name = "Spinnaker / Clouddriver"
    tags = ["clickstack", "spinnaker", "clouddriver"]
    tiles = [
      {
        name = "Controller Invocation Rate by Method"
        x = 0, y = 0, w = 12, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver-jasonmcintosh\""
          whereLanguage = "lucene"
          groupBy       = "Attributes['controller'],Attributes['method']"
          select = [{
            aggFn      = "count"
            metricType = "histogram"
            metricName = "controller.invocations"
            alias      = "invocations"
          }]
        }
      },
      {
        name = "5xx Error Rate by Controller"
        x = 12, y = 0, w = 12, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          # Only "2xx"/"4xx" have been observed in Attributes['status'] so far - this is
          # expected to render empty until clouddriver actually 5xxs, not a broken query.
          where         = "ServiceName:\"clouddriver-jasonmcintosh\" status:\"5xx\""
          whereLanguage = "lucene"
          groupBy       = "Attributes['controller'],Attributes['method']"
          select = [{
            aggFn      = "count"
            metricType = "histogram"
            metricName = "controller.invocations"
            alias      = "5xx errors"
          }]
        }
      },
      {
        name = "Controller Invocation Latency (p50) by Method"
        x = 0, y = 8, w = 12, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver-jasonmcintosh\""
          whereLanguage = "lucene"
          groupBy       = "Attributes['controller'],Attributes['method']"
          select = [{
            aggFn           = "quantile"
            level           = 0.5
            valueExpression = "Value"
            metricType      = "histogram"
            metricName      = "controller.invocations"
            alias           = "latency_p50_seconds"
          }]
        }
      },
      {
        name = "JVM Heap Memory Used"
        x = 12, y = 8, w = 12, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver-jasonmcintosh\" area:\"heap\""
          whereLanguage = "lucene"
          groupBy       = "Attributes['id']"
          select = [{
            aggFn           = "avg"
            valueExpression = "Value"
            metricType      = "gauge"
            metricName      = "jvm.memory.used"
            alias           = "heap used"
          }]
        }
      },
      {
        name = "JVM GC Pause Rate"
        x = 0, y = 16, w = 24, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver-jasonmcintosh\""
          whereLanguage = "lucene"
          select = [
            {
              aggFn      = "count"
              metricType = "histogram"
              metricName = "jvm.gc.pause"
              alias      = "pause_count"
            },
            {
              aggFn           = "quantile"
              level           = 0.5
              valueExpression = "Value"
              metricType      = "histogram"
              metricName      = "jvm.gc.pause"
              alias           = "pause_p50_seconds"
            }
          ]
        }
      }
    ]
  })
}

# Same panels as dashboards/clickhouse/ilo.json.tpl. Metric names and the "name" per-sensor
# label are now confirmed against the exporter's own /metrics output (curled directly via a
# throwaway pod) and against real rows in ClickHouse - both hosts in
# collector-and-ilo.yaml's static_configs (192.168.19.60 full sensor set,
# 192.168.18.128 power/system-info only, a real hardware/firmware difference) have reported
# successfully.
# groupBy is raw SQL, not a dimension name ClickStack resolves for you: a bare string
# groupBy is injected verbatim (see UNSAFE_RAW_SQL in hyperdxio/hyperdx's
# renderChartConfig.ts), so anything that isn't a real top-level column (ServiceName is)
# must be written as an explicit Attributes['key']/ResourceAttributes['key'] map access -
# same convention HyperDX's own built-in dashboard templates use (e.g.
# packages/app/src/dashboardTemplates/jvm-runtime-metrics.json's
# "Attributes['jvm.memory.pool.name']"). A bare key name either 404s as an unknown
# identifier (this dashboard's original "instance") or, worse, silently resolves to
# nothing if ClickHouse happens to accept it as some other identifier.
#
# groupBy uses "service.instance.id" (as ResourceAttributes['service.instance.id']), not
# the raw Prometheus "instance" label: the OTel Collector's prometheus receiver
# (collector-and-ilo.yaml) renames the scrape target's "instance"/"job" labels to the
# resource attributes "service.instance.id"/"service.name" respectively before export.
resource "clickhouse_clickstack_dashboard" "ilo" {
  provider = clickhouse.clickstack
  dashboard_json = jsonencode({
    name = "iLO"
    tags = ["clickstack", "ilo"]
    tiles = [
      {
        name = "Power Draw (Watts)"
        x = 0, y = 0, w = 24, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          groupBy       = "ResourceAttributes['service.instance.id']"
          select = [
            { aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_current_watt", alias = "current" },
            { aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_average_watt", alias = "average" },
            { aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_max_watt", alias = "max" }
          ]
        }
      },
      {
        name = "Chassis Temperature"
        x = 0, y = 8, w = 12, h = 8
        config = {
          displayType = "line"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "ResourceAttributes['service.instance.id'],Attributes['name']"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_chassis_temperature_current", alias = "temp" }]
        }
      },
      {
        name = "Fan Speed (%)"
        x = 12, y = 8, w = 12, h = 8
        config = {
          displayType = "line"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "ResourceAttributes['service.instance.id'],Attributes['name']"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_chassis_fan_current_percent", alias = "fan" }]
        }
      },
      {
        name = "Component Health (1 = healthy, worst-case in window)"
        x = 0, y = 16, w = 24, h = 8
        config = {
          displayType = "table"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "ResourceAttributes['service.instance.id']"
          select = [
            { aggFn = "min", valueExpression = "Value", metricType = "gauge", metricName = "ilo_processor_healthy", alias = "processor" },
            { aggFn = "min", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_supply_healthy", alias = "power_supply" },
            { aggFn = "min", valueExpression = "Value", metricType = "gauge", metricName = "ilo_storage_disk_healthy", alias = "disk" },
            { aggFn = "min", valueExpression = "Value", metricType = "gauge", metricName = "ilo_memory_dimm_healthy", alias = "memory" }
          ]
        }
      }
    ]
  })
}

# Same panels as dashboards/clickhouse/in-house.json.tpl - generic across any pod labeled
# type=spring-boot-app (see collector-gateway.yaml's spring-boot-apps scrape job), grouped
# by ServiceName instead of filtered to one service.
#
# "HTTP Request Rate" is a raw-SQL tile (configType = "sql"), not a metric-builder tile:
# Micrometer's Prometheus registry exports http.server.requests as a Summary (no percentile
# buckets configured), which the OTel Collector's prometheus receiver in turn reports as an
# OTel Summary metric - a metric kind ClickStack's metric-builder tiles have no support for
# (translateMetricChartConfig in hyperdxio/hyperdx's renderChartConfig.ts only handles
# Gauge/Sum/Histogram/ExponentialHistogram). Summary data lives in otel_metrics_summary with
# real Count/Sum columns (verified via the ClickHouse HTTP API), so this tile queries it
# directly using ClickStack's SQL-tile time-range parameters ({startDateMilliseconds:Int64}
# etc., ClickHouse's native `{name:Type}` query-param syntax - see
# hyperdxio/hyperdx's packages/common-utils/src/rawSqlParams.ts) instead of the metric
# builder's groupBy/select.
resource "clickhouse_clickstack_dashboard" "in_house" {
  provider = clickhouse.clickstack
  dashboard_json = jsonencode({
    name = "In-House Spring Boot Apps"
    tags = ["clickstack", "in-house"]
    tiles = [
      {
        name = "HTTP Request Rate by Service/URI"
        x = 0, y = 0, w = 24, h = 8
        config = {
          configType   = "sql"
          displayType  = "line"
          connectionId = clickhouse_clickstack_connection.main.id
          sqlTemplate  = "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL {intervalSeconds:Int64} second) AS time, concat(ServiceName, ' ', Attributes['uri'], ' ', Attributes['status']) AS metric, max(Count) AS value FROM otel.otel_metrics_summary WHERE MetricName = 'http_server_requests_seconds' AND TimeUnix >= fromUnixTimestamp64Milli({startDateMilliseconds:Int64}) AND TimeUnix <= fromUnixTimestamp64Milli({endDateMilliseconds:Int64}) GROUP BY time, metric) ORDER BY time"
        }
      },
      {
        name = "JVM Heap Memory Used"
        x = 0, y = 8, w = 12, h = 8
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "area:\"heap\""
          whereLanguage = "lucene"
          groupBy       = "ServiceName,Attributes['id']"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "jvm_memory_used_bytes", alias = "heap used" }]
        }
      },
      {
        name = "Process CPU Usage"
        x = 12, y = 8, w = 12, h = 8
        config = {
          displayType = "line"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "ServiceName"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "process_cpu_usage", alias = "cpu" }]
        }
      }
    ]
  })
}
