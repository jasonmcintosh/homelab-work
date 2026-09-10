{
  "title": "In-House Spring Boot Apps (ClickHouse)",
  "uid": "in-house-clickhouse",
  "schemaVersion": 39,
  "editable": true,
  "tags": ["clickhouse", "in-house"],
  "time": { "from": "now-6h", "to": "now" },
  "templating": {
    "list": [
      {
        "name": "service",
        "type": "query",
        "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
        "query": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm_threads_live_threads'",
        "refresh": 2,
        "includeAll": true,
        "multi": true
      }
    ]
  },
  "panels": [
    {
      "id": 1,
      "type": "timeseries",
      "title": "HTTP Request Rate by URI/Status",
      "description": "Standard Spring Boot Actuator metric (http_server_requests_seconds_count), generic across any in-house app labeled type=spring-boot-app in prometheus.yaml/collector-gateway.yaml's scrape config - unlike clouddriver.json.tpl, which uses clouddriver's own custom controller_invocations_* metrics.",
      "gridPos": { "x": 0, "y": 0, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) / 60 AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ServiceName, ' ', Attributes['uri'], ' ', Attributes['status']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'http_server_requests_seconds_count' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric) ORDER BY time"
        }
      ]
    },
    {
      "id": 2,
      "type": "timeseries",
      "title": "HTTP Request Latency (avg) by URI",
      "description": "rate(http_server_requests_seconds_sum) / rate(http_server_requests_seconds_count), same sum/count-delta join pattern used in clouddriver.json.tpl.",
      "gridPos": { "x": 0, "y": 8, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "WITH sum_rate AS (SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ServiceName, ' ', Attributes['uri']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'http_server_requests_seconds_sum' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric)), count_rate AS (SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ServiceName, ' ', Attributes['uri']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'http_server_requests_seconds_count' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric)) SELECT s.time AS time, s.metric AS metric, s.delta / nullIf(c.delta, 0) AS value FROM sum_rate s INNER JOIN count_rate c ON s.time = c.time AND s.metric = c.metric ORDER BY time"
        }
      ]
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "JVM Heap Memory Used",
      "description": "jvm_memory_used_bytes{area=\"heap\"}, gauge, no rate needed.",
      "gridPos": { "x": 0, "y": 16, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ServiceName, ' ', Attributes['id']) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm_memory_used_bytes' AND Attributes['area'] = 'heap' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    },
    {
      "id": 4,
      "type": "timeseries",
      "title": "Process CPU Usage",
      "description": "process_cpu_usage, gauge (0-1 fraction), no rate needed.",
      "gridPos": { "x": 12, "y": 16, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, ServiceName AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'process_cpu_usage' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    }
  ]
}
