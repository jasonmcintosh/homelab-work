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
      "description": "Hand-ported from clouddriver.json's '$Account Controller Invocation by Method' panel: sum(rate(controller_invocations_total[5m])) by (controller, method). ClickHouse has no rate() builtin, so this computes a per-minute delta of the monotonic counter via lagInFrame(). ServiceName/MetricName/Count verified against real data via the ClickHouse HTTP API: clouddriver reports over OTLP with Micrometer's native dotted names (Attributes/MetricName), not the Prometheus-exporter-style underscored names this panel originally assumed, and its ServiceName is the hostname-suffixed \"clouddriver-jasonmcintosh\", not \"clouddriver\". The invocation count is a Timer meter, so it lands in otel_metrics_histogram's cumulative Count column, not otel_metrics_sum (whose same-named rows are separately-reported percentile gauges, Attributes['statistic']='percentile' - not counts).",
      "gridPos": { "x": 0, "y": 0, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) / 60 AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND ServiceName = 'clouddriver-jasonmcintosh' AND $__timeFilter(TimeUnix) GROUP BY time, metric) ORDER BY time"
        }
      ]
    },
    {
      "id": 2,
      "type": "timeseries",
      "title": "5xx Error Rate by Controller",
      "description": "Hand-ported from '$Account 5xx Errors': sum(rate(controller_invocations_total{status=\"5xx\"}[5m])) by (controller, method). Same otel_metrics_histogram/ServiceName correction as the panel above - only \"2xx\"/\"4xx\" have been observed in Attributes['status'] so far, so this is expected to render empty until clouddriver actually 5xxs.",
      "gridPos": { "x": 12, "y": 0, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, greatest(value - lagInFrame(value) OVER (PARTITION BY metric ORDER BY time), 0) / 60 AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND ServiceName = 'clouddriver-jasonmcintosh' AND Attributes['status'] = '5xx' AND $__timeFilter(TimeUnix) GROUP BY time, metric) ORDER BY time"
        }
      ]
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "Controller Invocation Latency (avg) by Method",
      "description": "Hand-ported from '$Account Controller Invocation Latency by Method': rate(controller_invocations_seconds_sum[5m]) / rate(controller_invocations_seconds_count[5m]). \"controller_invocations_seconds_sum\"/\"_count\" don't exist for clouddriver (see the rate panel above) - the real sum/count pair is otel_metrics_histogram's Sum/Count columns on the same 'controller.invocations' rows, so both deltas come from one table scan instead of two CTEs joined.",
      "gridPos": { "x": 0, "y": 8, "w": 12, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, sum_delta / nullIf(count_delta, 0) AS value FROM (SELECT time, metric, greatest(sum_value - lagInFrame(sum_value) OVER (PARTITION BY metric ORDER BY time), 0) AS sum_delta, greatest(count_value - lagInFrame(count_value) OVER (PARTITION BY metric ORDER BY time), 0) AS count_delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, concat(Attributes['controller'], '.', Attributes['method']) AS metric, max(Sum) AS sum_value, max(Count) AS count_value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND ServiceName = 'clouddriver-jasonmcintosh' AND $__timeFilter(TimeUnix) GROUP BY time, metric)) ORDER BY time"
        }
      ]
    },
    {
      "id": 4,
      "type": "timeseries",
      "title": "JVM Heap Memory Used",
      "description": "Hand-ported from 'JVM Memory Usage': sum(jvm_memory_used_bytes{area=\"heap\"}) by (id). Gauge metric, no rate needed. Real name is the dotted \"jvm.memory.used\" (clouddriver's native OTLP export keeps Micrometer's dotted names, unlike Prometheus-scraped services) and ServiceName is \"clouddriver-jasonmcintosh\".",
      "gridPos": { "x": 12, "y": 8, "w": 12, "h": 8 },
      "fieldConfig": { "defaults": { "unit": "bytes" } },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, Attributes['id'] AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND ServiceName = 'clouddriver-jasonmcintosh' AND Attributes['area'] = 'heap' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    },
    {
      "id": 5,
      "type": "timeseries",
      "title": "JVM GC Pause Rate",
      "description": "Hand-ported from 'JVM GC Average Pause Seconds': rate(jvm_gc_pause_seconds_sum[5m]) / rate(jvm_gc_pause_seconds_count[5m]). Real name is the dotted \"jvm.gc.pause\" Timer, whose Sum/Count live in otel_metrics_histogram (same correction as the latency panel above), ServiceName \"clouddriver-jasonmcintosh\".",
      "gridPos": { "x": 0, "y": 16, "w": 24, "h": 8 },
      "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
      "targets": [
        {
          "refId": "A",
          "datasource": { "type": "grafana-clickhouse-datasource", "uid": "${ch_uid}" },
          "format": 0,
          "rawSql": "SELECT time, metric, sum_delta / nullIf(count_delta, 0) AS value FROM (SELECT time, metric, greatest(sum_value - lagInFrame(sum_value) OVER (PARTITION BY metric ORDER BY time), 0) AS sum_delta, greatest(count_value - lagInFrame(count_value) OVER (PARTITION BY metric ORDER BY time), 0) AS count_delta FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL 1 MINUTE) AS time, ServiceName AS metric, max(Sum) AS sum_value, max(Count) AS count_value FROM otel.otel_metrics_histogram WHERE MetricName = 'jvm.gc.pause' AND ServiceName = 'clouddriver-jasonmcintosh' AND $__timeFilter(TimeUnix) GROUP BY time, metric)) ORDER BY time"
        }
      ]
    }
  ]
}
