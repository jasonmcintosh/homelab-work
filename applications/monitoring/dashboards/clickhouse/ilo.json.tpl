{
  "title": "iLO (ClickHouse)",
  "uid": "ilo-clickhouse",
  "schemaVersion": 39,
  "editable": true,
  "tags": ["clickhouse", "ilo"],
  "time": { "from": "now-24h", "to": "now" },
  "panels": [
    {
      "id": 1,
      "type": "timeseries",
      "title": "Power Draw (Watts)",
      "description": "ilo_power_current_watt / ilo_power_average_watt / ilo_power_min_watt / ilo_power_max_watt, by host (ResourceAttributes['service.instance.id'] is the ilo IP set by collector-and-ilo.yaml's relabel_configs - the OTel Collector's prometheus receiver renames the scrape target's \"instance\" label to the resource attribute \"service.instance.id\" on export, so it isn't a plain \"instance\" key). No existing Grafana source dashboard for iLO was checked in - authored directly from the ilo_exporter's published metric names (MauveSoftware/ilo_exporter).",
      "gridPos": { "x": 0, "y": 0, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ResourceAttributes['service.instance.id'], ' ', MetricName) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName IN ('ilo_power_current_watt', 'ilo_power_average_watt', 'ilo_power_min_watt', 'ilo_power_max_watt') AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    },
    {
      "id": 2,
      "type": "timeseries",
      "title": "Chassis Temperature (°C)",
      "description": "ilo_chassis_temperature_current by host. Verify the per-sensor label name once real data lands: SELECT DISTINCT arrayJoin(mapKeys(Attributes)) FROM otel.otel_metrics_gauge WHERE MetricName='ilo_chassis_temperature_current' - adjust the Attributes['name'] key below if the exporter uses a different label.",
      "gridPos": { "x": 0, "y": 8, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ResourceAttributes['service.instance.id'], ' ', Attributes['name']) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_temperature_current' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "Fan Speed (%)",
      "description": "ilo_chassis_fan_current_percent by host/fan.",
      "gridPos": { "x": 12, "y": 8, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ResourceAttributes['service.instance.id'], ' ', Attributes['name']) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_fan_current_percent' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    },
    {
      "id": 4,
      "type": "table",
      "title": "Component Health (1 = healthy)",
      "description": "Latest value of ilo_processor_healthy / ilo_power_supply_healthy / ilo_storage_disk_healthy / ilo_memory_dimm_healthy per host - a fast at-a-glance health check rather than a time series.",
      "gridPos": { "x": 0, "y": 16, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 1,
          "rawSql": "SELECT ResourceAttributes['service.instance.id'] AS host, MetricName AS component, argMax(Value, TimeUnix) AS healthy FROM otel.otel_metrics_gauge WHERE MetricName IN ('ilo_processor_healthy', 'ilo_power_supply_healthy', 'ilo_storage_disk_healthy', 'ilo_memory_dimm_healthy') AND $__timeFilter(TimeUnix) GROUP BY host, component ORDER BY host, component"
        }
      ]
    }
  ]
}
