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
      "description": "Standard Spring Boot Actuator metric (http_server_requests_seconds), generic across any in-house app labeled type=spring-boot-app in prometheus.yaml/collector-gateway.yaml's scrape config - unlike clouddriver.json.tpl, which uses clouddriver's own custom controller_invocations_* metrics. \"http_server_requests_seconds_count\" doesn't exist: Micrometer's Prometheus registry exports this Timer without percentile buckets, which Prometheus (and in turn the OTel Collector's prometheus receiver) treats as a Summary, not a plain counter - it lands whole, base-named, in otel_metrics_summary with real Count/Sum columns (verified via the ClickHouse HTTP API), not as separate otel_metrics_sum \"_count\" rows.",
      "gridPos": { "x": 0, "y": 0, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) / 60 AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ServiceName, ' ', Attributes['uri'], ' ', Attributes['status']) AS metric, max(Count) AS value FROM otel.otel_metrics_summary WHERE MetricName = 'http_server_requests_seconds' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric) ORDER BY time"
        }
      ]
    },
    {
      "id": 2,
      "type": "timeseries",
      "title": "HTTP Request Latency (avg) by URI",
      "description": "rate(http_server_requests_seconds_sum) / rate(http_server_requests_seconds_count). Same otel_metrics_summary correction as the rate panel above - Sum and Count are columns on the same row there, so both deltas come from one table scan instead of two CTEs joined.",
      "gridPos": { "x": 0, "y": 8, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, sum_delta / nullIf(count_delta, 0) AS value FROM (SELECT time, metric, greatest(sum_value - lagInFrame(sum_value) OVER (PARTITION BY metric ORDER BY time), 0) AS sum_delta, greatest(count_value - lagInFrame(count_value) OVER (PARTITION BY metric ORDER BY time), 0) AS count_delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(ServiceName, ' ', Attributes['uri']) AS metric, max(Sum) AS sum_value, max(Count) AS count_value FROM otel.otel_metrics_summary WHERE MetricName = 'http_server_requests_seconds' AND ServiceName IN ($${service:sqlstring}) AND $__timeFilter(TimeUnix) GROUP BY time, metric)) ORDER BY time"
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
