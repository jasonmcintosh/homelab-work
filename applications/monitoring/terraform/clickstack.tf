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
resource "clickhouse_clickstack_dashboard" "clouddriver" {
  provider = clickhouse.clickstack
  dashboard_json = jsonencode({
    name = "Spinnaker / Clouddriver"
    tags = ["clickstack", "spinnaker", "clouddriver"]
    tiles = [
      {
        name = "Controller Invocation Rate by Method"
        x = 0, y = 0, w = 6, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver\""
          whereLanguage = "lucene"
          groupBy       = "controller,method"
          select = [{
            aggFn           = "sum"
            valueExpression = "Value"
            metricType      = "sum"
            metricName      = "controller_invocations_total"
            alias           = "invocations"
          }]
        }
      },
      {
        name = "5xx Error Rate by Controller"
        x = 6, y = 0, w = 6, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver\" status:\"5xx\""
          whereLanguage = "lucene"
          groupBy       = "controller,method"
          select = [{
            aggFn           = "sum"
            valueExpression = "Value"
            metricType      = "sum"
            metricName      = "controller_invocations_total"
            alias           = "5xx errors"
          }]
        }
      },
      {
        name = "Controller Invocation Latency (avg) by Method"
        x = 0, y = 3, w = 6, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver\""
          whereLanguage = "lucene"
          groupBy       = "controller,method"
          select = [
            {
              aggFn           = "sum"
              valueExpression = "Value"
              metricType      = "sum"
              metricName      = "controller_invocations_seconds_sum"
              alias           = "time_sum"
            },
            {
              aggFn           = "sum"
              valueExpression = "Value"
              metricType      = "sum"
              metricName      = "controller_invocations_seconds_count"
              alias           = "time_count"
            }
          ]
        }
      },
      {
        name = "JVM Heap Memory Used"
        x = 6, y = 3, w = 6, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver\" area:\"heap\""
          whereLanguage = "lucene"
          groupBy       = "id"
          select = [{
            aggFn           = "avg"
            valueExpression = "Value"
            metricType      = "gauge"
            metricName      = "jvm_memory_used_bytes"
            alias           = "heap used"
          }]
        }
      },
      {
        name = "JVM GC Pause Rate"
        x = 0, y = 6, w = 12, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "ServiceName:\"clouddriver\""
          whereLanguage = "lucene"
          select = [
            {
              aggFn           = "sum"
              valueExpression = "Value"
              metricType      = "sum"
              metricName      = "jvm_gc_pause_seconds_sum"
              alias           = "pause_sum"
            },
            {
              aggFn           = "sum"
              valueExpression = "Value"
              metricType      = "sum"
              metricName      = "jvm_gc_pause_seconds_count"
              alias           = "pause_count"
            }
          ]
        }
      }
    ]
  })
}

# Same panels as dashboards/clickhouse/ilo.json.tpl. Metric names are grounded against the
# published MauveSoftware/ilo_exporter community Grafana dashboard (grafana.com/grafana/
# dashboards/20212-ilo/) - verify the exact per-sensor label name (used here as "name") once
# real data lands, same caveat as the Grafana version of this dashboard.
# groupBy uses "service.instance.id", not the raw Prometheus "instance" label: the OTel
# Collector's prometheus receiver (collector-and-ilo.yaml) renames the scrape target's
# "instance"/"job" labels to the resource attributes "service.instance.id"/"service.name"
# respectively before export, so "instance" itself doesn't exist as a column/attribute -
# using it produced "Unknown expression identifier `instance`" from ClickHouse.
resource "clickhouse_clickstack_dashboard" "ilo" {
  provider = clickhouse.clickstack
  dashboard_json = jsonencode({
    name = "iLO"
    tags = ["clickstack", "ilo"]
    tiles = [
      {
        name = "Power Draw (Watts)"
        x = 0, y = 0, w = 12, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          groupBy       = "service.instance.id"
          select = [
            { aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_current_watt", alias = "current" },
            { aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_average_watt", alias = "average" },
            { aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_power_max_watt", alias = "max" }
          ]
        }
      },
      {
        name = "Chassis Temperature"
        x = 0, y = 3, w = 6, h = 3
        config = {
          displayType = "line"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "service.instance.id,name"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_chassis_temperature_current", alias = "temp" }]
        }
      },
      {
        name = "Fan Speed (%)"
        x = 6, y = 3, w = 6, h = 3
        config = {
          displayType = "line"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "service.instance.id,name"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "ilo_chassis_fan_current_percent", alias = "fan" }]
        }
      },
      {
        name = "Component Health (1 = healthy, worst-case in window)"
        x = 0, y = 6, w = 12, h = 3
        config = {
          displayType = "table"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "service.instance.id"
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
resource "clickhouse_clickstack_dashboard" "in_house" {
  provider = clickhouse.clickstack
  dashboard_json = jsonencode({
    name = "In-House Spring Boot Apps"
    tags = ["clickstack", "in-house"]
    tiles = [
      {
        name = "HTTP Request Rate by Service/URI"
        x = 0, y = 0, w = 12, h = 3
        config = {
          displayType = "line"
          sourceId    = clickhouse_clickstack_source.metrics.id
          groupBy     = "ServiceName,uri"
          select = [{ aggFn = "sum", valueExpression = "Value", metricType = "sum", metricName = "http_server_requests_seconds_count", alias = "requests" }]
        }
      },
      {
        name = "JVM Heap Memory Used"
        x = 0, y = 3, w = 6, h = 3
        config = {
          displayType   = "line"
          sourceId      = clickhouse_clickstack_source.metrics.id
          where         = "area:\"heap\""
          whereLanguage = "lucene"
          groupBy       = "ServiceName,id"
          select = [{ aggFn = "avg", valueExpression = "Value", metricType = "gauge", metricName = "jvm_memory_used_bytes", alias = "heap used" }]
        }
      },
      {
        name = "Process CPU Usage"
        x = 6, y = 3, w = 6, h = 3
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
