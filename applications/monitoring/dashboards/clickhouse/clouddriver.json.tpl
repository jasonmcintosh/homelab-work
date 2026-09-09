{
  "title": "Spinnaker / Clouddriver (ClickHouse)",
  "uid": "clouddriver-clickhouse",
  "schemaVersion": 39,
  "editable": true,
  "tags": ["clickhouse", "spinnaker", "clouddriver"],
  "time": { "from": "now-6h", "to": "now" },
  "panels": [
    {
      "id": 1,
      "type": "timeseries",
      "title": "Controller Invocation Rate by Method",
      "description": "Hand-ported from clouddriver.json's '$Account Controller Invocation by Method' panel: sum(rate(controller_invocations_total[5m])) by (controller, method). ClickHouse has no rate() builtin, so this computes a per-minute delta of the monotonic counter via lagInFrame().",
      "gridPos": { "x": 0, "y": 0, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": "time_series",
          "rawSql": "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) / 60 AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'controller_invocations_total' AND ServiceName = 'clouddriver' AND $__timeFilter(TimeUnix) GROUP BY time, metric) ORDER BY time"
        }
      ]
    },
    {
      "id": 2,
      "type": "timeseries",
      "title": "5xx Error Rate by Controller",
      "description": "Hand-ported from '$Account 5xx Errors': sum(rate(controller_invocations_total{status=\"5xx\"}[5m])) by (controller, method).",
      "gridPos": { "x": 12, "y": 0, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": "time_series",
          "rawSql": "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) / 60 AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'controller_invocations_total' AND ServiceName = 'clouddriver' AND Attributes['status'] = '5xx' AND $__timeFilter(TimeUnix) GROUP BY time, metric) ORDER BY time"
        }
      ]
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "Controller Invocation Latency (avg) by Method",
      "description": "Hand-ported from '$Account Controller Invocation Latency by Method': rate(controller_invocations_seconds_sum[5m]) / rate(controller_invocations_seconds_count[5m]). Computed here as two independent per-minute counter deltas joined on (time, metric).",
      "gridPos": { "x": 0, "y": 8, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": "time_series",
          "rawSql": "WITH sum_rate AS (SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'controller_invocations_seconds_sum' AND ServiceName = 'clouddriver' AND $__timeFilter(TimeUnix) GROUP BY time, metric)), count_rate AS (SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'controller_invocations_seconds_count' AND ServiceName = 'clouddriver' AND $__timeFilter(TimeUnix) GROUP BY time, metric)) SELECT s.time AS time, s.metric AS metric, s.delta / nullIf(c.delta, 0) AS value FROM sum_rate s INNER JOIN count_rate c ON s.time = c.time AND s.metric = c.metric ORDER BY time"
        }
      ]
    },
    {
      "id": 4,
      "type": "timeseries",
      "title": "JVM Heap Memory Used",
      "description": "Hand-ported from 'JVM Memory Usage': sum(jvm_memory_used_bytes{area=\"heap\"}) by (id). Gauge metric, no rate needed.",
      "gridPos": { "x": 12, "y": 8, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": "time_series",
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, Attributes['id'] AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm_memory_used_bytes' AND ServiceName = 'clouddriver' AND Attributes['area'] = 'heap' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    },
    {
      "id": 5,
      "type": "timeseries",
      "title": "JVM GC Pause Rate",
      "description": "Hand-ported from 'JVM GC Average Pause Seconds': rate(jvm_gc_pause_seconds_sum[5m]) / rate(jvm_gc_pause_seconds_count[5m]), same sum/count-delta join pattern as the latency panel above.",
      "gridPos": { "x": 0, "y": 16, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": "time_series",
          "rawSql": "WITH sum_rate AS (SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, ServiceName AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'jvm_gc_pause_seconds_sum' AND ServiceName = 'clouddriver' AND $__timeFilter(TimeUnix) GROUP BY time, metric)), count_rate AS (SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) AS delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, ServiceName AS metric, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'jvm_gc_pause_seconds_count' AND ServiceName = 'clouddriver' AND $__timeFilter(TimeUnix) GROUP BY time, metric)) SELECT s.time AS time, s.metric AS metric, s.delta / nullIf(c.delta, 0) AS value FROM sum_rate s INNER JOIN count_rate c ON s.time = c.time AND s.metric = c.metric ORDER BY time"
        }
      ]
    }
  ]
}
