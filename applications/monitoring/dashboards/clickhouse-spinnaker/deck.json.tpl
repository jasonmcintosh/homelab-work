{
  "title": "Deck (ClickHouse)",
  "uid": "ch-spinnaker-deck",
  "schemaVersion": 39,
  "editable": true,
  "refresh": "1m",
  "tags": [
    "clickhouse",
    "spinnaker"
  ],
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "links": [
    {
      "asDropdown": true,
      "icon": "info",
      "includeVars": false,
      "keepTime": false,
      "tags": [],
      "targetBlank": false,
      "title": "GitHub",
      "type": "link",
      "url": "https://github.com/spinnaker/deck"
    }
  ],
  "templating": {
    "list": [
      {
        "name": "spinSvc",
        "label": "",
        "type": "custom",
        "query": "deck",
        "current": {
          "text": "echo",
          "value": "echo"
        },
        "options": [
          {
            "text": "deck",
            "value": "deck"
          }
        ],
        "multi": false,
        "includeAll": false,
        "hide": 2
      },
      {
        "name": "job",
        "label": "job",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND match(ServiceName, '^(?:.*deck.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND match(ServiceName, '^(?:.*deck.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
        },
        "refresh": 2,
        "multi": true,
        "includeAll": true,
        "current": {
          "selected": true,
          "text": "All",
          "value": "$__all"
        },
        "sort": 1,
        "hide": 0
      },
      {
        "name": "Instance",
        "label": "Instance",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND ServiceName IN ($job) AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND ServiceName IN ($job) AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
        },
        "refresh": 2,
        "multi": true,
        "includeAll": true,
        "current": {
          "selected": true,
          "text": "All",
          "value": "$__all"
        },
        "sort": 1,
        "hide": 0
      }
    ]
  },
  "panels": [
    {
      "id": 1,
      "type": "row",
      "title": "Key Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 0,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 2,
      "type": "text",
      "title": "Service Description",
      "gridPos": {
        "x": 0,
        "y": 1,
        "w": 6,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "Deck is the browser-based UI.\n\nIt is built on Apache2 which does not natively serve a Prometheus metrics endpoint."
      }
    },
    {
      "id": 3,
      "type": "row",
      "title": "Kubernetes Pod Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 9,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 4,
      "type": "timeseries",
      "title": "CPU",
      "description": "CPU Usage. Average is the average usage across all instances, max is the highest usage across all instances. As CPU Usage is a sampled metric it is best to view in relation to throttling percentage.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 10,
        "w": 6,
        "h": 8
      },
      "interval": "1m",
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'avg' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_usage_seconds_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] IN ($spinSvc) GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'max' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_usage_seconds_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] IN ($spinSvc) GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percentunit",
          "custom": {
            "fillOpacity": 0,
            "lineWidth": 1,
            "stacking": {
              "mode": "none"
            },
            "spanNulls": false
          }
        },
        "overrides": []
      },
      "options": {
        "legend": {
          "showLegend": true,
          "displayMode": "list",
          "placement": "bottom",
          "calcs": []
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      }
    },
    {
      "id": 5,
      "type": "timeseries",
      "title": "CPU Throttling",
      "description": "Percent of the time that the CPU is being throttled. Application may be getting throttled during bursty tasks but overall be well below its CPU limit. Throttling may significantly impact application performance.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 10,
        "w": 6,
        "h": 8
      },
      "interval": "1m",
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `pod` AS metric, value FROM (SELECT time, `pod`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_cfs_throttled_periods_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] IN ($spinSvc) GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) AS a ALL INNER JOIN (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_cfs_periods_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] IN ($spinSvc) GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) AS b USING (time, `pod`)) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percentunit",
          "custom": {
            "fillOpacity": 10,
            "lineWidth": 1,
            "stacking": {
              "mode": "none"
            },
            "spanNulls": false
          }
        },
        "overrides": []
      },
      "options": {
        "legend": {
          "showLegend": true,
          "displayMode": "list",
          "placement": "bottom",
          "calcs": []
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      }
    },
    {
      "id": 6,
      "type": "timeseries",
      "title": "Memory",
      "description": "Memory utilisation. Average is the average usage across all instaces, max is the highest usage across all instances.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 10,
        "w": 6,
        "h": 8
      },
      "interval": "1m",
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'avg' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'container_memory_working_set_bytes' AND $__timeFilter(TimeUnix) AND Attributes['container'] IN ($spinSvc) GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'max' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'container_memory_working_set_bytes' AND $__timeFilter(TimeUnix) AND Attributes['container'] IN ($spinSvc) GROUP BY time, series) GROUP BY time) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "decbytes",
          "custom": {
            "fillOpacity": 0,
            "lineWidth": 1,
            "stacking": {
              "mode": "none"
            },
            "spanNulls": false
          }
        },
        "overrides": []
      },
      "options": {
        "legend": {
          "showLegend": true,
          "displayMode": "list",
          "placement": "bottom",
          "calcs": []
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      }
    },
    {
      "id": 7,
      "type": "timeseries",
      "title": "Network",
      "description": "Average network ingress/egress for the $spinSvc pods.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 10,
        "w": 6,
        "h": 8
      },
      "interval": "1m",
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'receive' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_network_receive_bytes_total' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['pod'], concat('^(?:spin-', x, '.*)$')), [$spinSvc]) GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'transmit' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_network_transmit_bytes_total' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['pod'], concat('^(?:spin-', x, '.*)$')), [$spinSvc]) GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) GROUP BY time) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "Bps",
          "custom": {
            "fillOpacity": 10,
            "lineWidth": 1,
            "stacking": {
              "mode": "none"
            },
            "spanNulls": false
          }
        },
        "overrides": []
      },
      "options": {
        "legend": {
          "showLegend": true,
          "displayMode": "list",
          "placement": "bottom",
          "calcs": []
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      }
    }
  ]
}
