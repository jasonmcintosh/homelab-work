{
  "title": "Spinnaker Key Metrics (ClickHouse)",
  "uid": "ch-spinnaker-key-metrics",
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
  "links": [],
  "templating": {
    "list": []
  },
  "panels": [
    {
      "id": 1,
      "type": "row",
      "title": "Monitoring Spinnaker, SLA Metrics",
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
      "title": "Monitoring Spinnaker, SLA Metrics",
      "gridPos": {
        "x": 0,
        "y": 1,
        "w": 6,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "\n# Monitoring Spinnaker, SLA Metrics\n\n[Medium blog by Rob Zienert](https://blog.spinnaker.io/monitoring-spinnaker-sla-metrics-a408754f6b7b)\n\n> What are the key metrics we can track that help quickly answer the question, \"Is Spinnaker healthy?\""
      }
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "Rate of Echo Triggers & Processed Events",
      "description": "echo.triggers.count tracks the number of CRON-triggered pipeline executions fired. \n\nThis value should be pretty steady, so any significant deviation is an indicator of something going awry (or the addition/retirement of a customer integration).\n\n\necho.pubsub.messagesProcessed is important if you have any PubSub triggers. \n\nYour mileage may vary, but Netflix can alert if any subscriptions drop to zero for more than a few minutes.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 1,
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
          "rawSql": "SELECT time, 'triggers/s' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'echo.triggers.count' AND $__timeFilter(TimeUnix) GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'events processed/s' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'echo.events.processed' AND $__timeFilter(TimeUnix) GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "id": 4,
      "type": "timeseries",
      "title": "Igor",
      "description": "pollingMonitor.failed tracks the failure rate of CI/SCM monitor poll cycles. \n\nAny value above 0 is a bad place to be, but is often a result of downstream service availability issues such as Jenkins going offline for maintenance.\n\npollingMonitor.itemsOverThreshold tracks a polling monitor circuit breaker. \n\nAny value over 0 is a bad time, because it means the breaker is open for a particular monitor and it requires manual intervention.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 1,
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
          "rawSql": "SELECT time, concat('partition=', `partition`) AS metric, value FROM (SELECT time, `partition`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['partition'] AS `partition`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'pollingMonitor.newItems' AND $__timeFilter(TimeUnix) GROUP BY time, series, `partition`) GROUP BY time, `partition`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('partition=', `partition`) AS metric, value FROM (SELECT time, `partition`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['partition'] AS `partition`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'pollingMonitor.failed' AND $__timeFilter(TimeUnix) GROUP BY time, series, `partition`) GROUP BY time, `partition`) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('partition=', `partition`) AS metric, value FROM (SELECT time, `partition`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['partition'] AS `partition`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'pollingMonitor.itemsOverThreshold' AND $__timeFilter(TimeUnix) GROUP BY time, series, `partition`) GROUP BY time, `partition`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "id": 5,
      "type": "timeseries",
      "title": "Controller Invocations Rate",
      "description": "All Spinnaker services are RPC-based, and as such, the reliability of requests inbound and outbound are supremely important: If the services can\u2019t talk to each other reliably, someone will be having a poor experience.\n\n\nTODO: Add Recording Rules so don't melt Prometheus",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 1,
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
          "rawSql": "SELECT time, concat(`status`, ' :: ', `container`) AS metric, value FROM (SELECT time, `container`, `status`, sum(value) AS value FROM (SELECT time, `container`, `status`, d / dt AS value FROM (SELECT time, `container`, `status`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['container'] AS `container`, Attributes['status'] AS `status`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) GROUP BY time, series, `container`, `status`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `container`, `status`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "title": "HTTP RPC Rate",
      "description": "Each service emits metrics for each RPC client that is configured via okhttp.requests.\n\nHaving SLOs \u2014 and consequentially, alerts \u2014 around failure rate (determined via the succcess tag) and latency for both inbound and outbound RPC requests is, in my mind, mandatory across all Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 9,
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
          "rawSql": "SELECT time, concat('container=', `container`) AS metric, value FROM (SELECT time, `container`, `requestHost`, `status`, sum(value) AS value FROM (SELECT time, `container`, `requestHost`, `status`, d / dt AS value FROM (SELECT time, `container`, `requestHost`, `status`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['container'] AS `container`, Attributes['requestHost'] AS `requestHost`, Attributes['status'] AS `status`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'okhttp.requests' AND $__timeFilter(TimeUnix) GROUP BY time, series, `container`, `requestHost`, `status`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `container`, `requestHost`, `status`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "id": 7,
      "type": "timeseries",
      "title": "Clouddriver AWS Cache Drift",
      "description": "cache.drift tracks cache freshness. \n\nYou should group this by agent and region to be granular on exactly what cache collection is falling behind. How much lag is acceptable for your org is up to you, but don\u2019t make it zero.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 9,
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
          "rawSql": "SELECT time, concat('account=', `account`) AS metric, value FROM (SELECT time, `account`, `agent`, `region`, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['account'] AS `account`, Attributes['agent'] AS `agent`, Attributes['region'] AS `region`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'cache.drift' AND $__timeFilter(TimeUnix) GROUP BY time, series, `account`, `agent`, `region`) GROUP BY time, `account`, `agent`, `region`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "dtdurations",
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
      "id": 8,
      "type": "text",
      "title": "Caching Agent Failures",
      "gridPos": {
        "x": 12,
        "y": 9,
        "w": 6,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "Not available from ClickHouse.\n\n\n\nPrometheus original: ``"
      }
    },
    {
      "id": 9,
      "type": "text",
      "title": "Clouddriver Kubernetes / Other Provider Cache",
      "gridPos": {
        "x": 18,
        "y": 9,
        "w": 6,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "Not available from ClickHouse.\n\n\n\nPrometheus original: ``"
      }
    }
  ]
}
