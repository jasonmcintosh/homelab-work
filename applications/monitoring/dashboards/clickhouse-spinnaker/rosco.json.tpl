{
  "title": "Rosco (ClickHouse)",
  "uid": "ch-spinnaker-rosco",
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
      "url": "https://github.com/spinnaker/rosco"
    }
  ],
  "templating": {
    "list": [
      {
        "name": "spinSvc",
        "label": "",
        "type": "custom",
        "query": "rosco",
        "current": {
          "text": "rosco",
          "value": "rosco"
        },
        "options": [
          {
            "text": "rosco",
            "value": "rosco"
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
        "definition": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND match(ServiceName, '^(?:.*rosco.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND match(ServiceName, '^(?:.*rosco.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "w": 12,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "Rosco is Spinnaker's bakery, producing machine images with Hashicorp Packer and rendered manifests with templating engines Helm and Kustomize."
      }
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "Active Bakes (rosco, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, concat('Active/', `instance`) AS metric, value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'bakesActive' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`) GROUP BY time, `instance`) ORDER BY time"
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
      "title": "Bake Request Rate (rosco, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, `flavor` AS metric, value FROM (SELECT time, `flavor`, sum(value) AS value FROM (SELECT time, `flavor`, d / dt AS value FROM (SELECT time, `flavor`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['flavor'] AS `flavor`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'bakesRequested' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `flavor`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `flavor`) ORDER BY time"
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
      "title": "Bake Failure Rate (rosco, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, concat(`cause`, '/', `region`) AS metric, value FROM (SELECT time, `cause`, `region`, sum(value) AS value FROM (SELECT time, `cause`, `region`, d / dt AS value FROM (SELECT time, `cause`, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cause'] AS `cause`, Attributes['region'] AS `region`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'false' GROUP BY time, series, `cause`, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cause`, `region`) ORDER BY time"
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
      "title": "Bake Succees Rate (rosco, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, concat('/', `region`) AS metric, value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, d / dt AS value FROM (SELECT time, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`) ORDER BY time"
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
      "title": "Bake Failure Duration (rosco, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
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
          "rawSql": "SELECT time, concat(`cause`, '/', `region`) AS metric, value FROM (SELECT time, `cause`, `region`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `cause`, `region`, sum(value) AS value FROM (SELECT time, `cause`, `region`, sum(value) AS value FROM (SELECT time, `cause`, `region`, d / dt AS value FROM (SELECT time, `cause`, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cause'] AS `cause`, Attributes['region'] AS `region`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'false' GROUP BY time, series, `cause`, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cause`, `region`) GROUP BY time, `cause`, `region`) AS a ALL INNER JOIN (SELECT time, `cause`, `region`, sum(value) AS value FROM (SELECT time, `cause`, `region`, sum(value) AS value FROM (SELECT time, `cause`, `region`, d / dt AS value FROM (SELECT time, `cause`, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cause'] AS `cause`, Attributes['region'] AS `region`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'false' GROUP BY time, series, `cause`, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cause`, `region`) GROUP BY time, `cause`, `region`) AS b USING (time, `cause`, `region`)) ORDER BY time"
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
      "type": "timeseries",
      "title": "Bake Success Duration (rosco, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
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
          "rawSql": "SELECT time, `region` AS metric, value FROM (SELECT time, `region`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, d / dt AS value FROM (SELECT time, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`) GROUP BY time, `region`) AS a ALL INNER JOIN (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, d / dt AS value FROM (SELECT time, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`) GROUP BY time, `region`) AS b USING (time, `region`)) ORDER BY time"
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
      "id": 9,
      "type": "row",
      "title": "HTTP Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 17,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 10,
      "type": "timeseries",
      "title": "Inbound Request Rate by Method",
      "description": "Inbound HTTP requests. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 18,
        "w": 8,
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
          "rawSql": "SELECT time, concat(`controller`, '/', `method`) AS metric, value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, d / dt AS value FROM (SELECT time, `controller`, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `controller`, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`) ORDER BY time"
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
      "id": 11,
      "type": "timeseries",
      "title": "Inbound Request Latency by Method",
      "description": "Inbound HTTP request latencies. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 8,
        "y": 18,
        "w": 8,
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
          "rawSql": "SELECT time, concat(`controller`, '/', `method`) AS metric, value FROM (SELECT time, `controller`, `method`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, d / dt AS value FROM (SELECT time, `controller`, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `controller`, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`) GROUP BY time, `controller`, `method`) AS a ALL INNER JOIN (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, d / dt AS value FROM (SELECT time, `controller`, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `controller`, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`) GROUP BY time, `controller`, `method`) AS b USING (time, `controller`, `method`)) ORDER BY time"
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
      "id": 12,
      "type": "timeseries",
      "title": "Inbound Request Errors by Method",
      "description": "Inbound HTTP request errors. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 16,
        "y": 18,
        "w": 8,
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `cause`, '/', `controller`, '/', `method`) AS metric, value FROM (SELECT time, `statusCode`, `cause`, `controller`, `method`, sum(value) AS value FROM (SELECT time, `cause`, `controller`, `method`, `statusCode`, d / dt AS value FROM (SELECT time, `cause`, `controller`, `method`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cause'] AS `cause`, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['status'] = '5xx' GROUP BY time, series, `cause`, `controller`, `method`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `statusCode`, `cause`, `controller`, `method`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`statusCode`, '/', `cause`, '/', `controller`, '/', `method`) AS metric, value FROM (SELECT time, `statusCode`, `cause`, `controller`, `method`, sum(value) AS value FROM (SELECT time, `cause`, `controller`, `method`, `statusCode`, d / dt AS value FROM (SELECT time, `cause`, `controller`, `method`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cause'] AS `cause`, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] = '429' GROUP BY time, series, `cause`, `controller`, `method`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `statusCode`, `cause`, `controller`, `method`) ORDER BY time"
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
      "id": 13,
      "type": "timeseries",
      "title": "Outbound Request Rate",
      "description": "Rate of outbound http requests to other Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 26,
        "w": 8,
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
          "rawSql": "SELECT time, `requestHost` AS metric, value FROM (SELECT time, `requestHost`, sum(value) AS value FROM (SELECT time, `requestHost`, d / dt AS value FROM (SELECT time, `requestHost`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestHost'] AS `requestHost`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'okhttp.requests' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `requestHost`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestHost`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "id": 14,
      "type": "timeseries",
      "title": "Outbound Request Latency",
      "description": "Latency of outbound http requests to other Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 8,
        "y": 26,
        "w": 8,
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
          "rawSql": "SELECT time, `requestHost` AS metric, value FROM (SELECT time, `requestHost`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `requestHost`, sum(value) AS value FROM (SELECT time, `requestHost`, sum(value) AS value FROM (SELECT time, `requestHost`, d / dt AS value FROM (SELECT time, `requestHost`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestHost'] AS `requestHost`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'okhttp.requests' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `requestHost`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestHost`) GROUP BY time, `requestHost`) AS a ALL INNER JOIN (SELECT time, `requestHost`, sum(value) AS value FROM (SELECT time, `requestHost`, sum(value) AS value FROM (SELECT time, `requestHost`, d / dt AS value FROM (SELECT time, `requestHost`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestHost'] AS `requestHost`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'okhttp.requests' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `requestHost`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestHost`) GROUP BY time, `requestHost`) AS b USING (time, `requestHost`)) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "dtdurations",
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
      "id": 15,
      "type": "timeseries",
      "title": "Outbound Request Error Rate",
      "description": "Rate of outbound http request errors when calling other Spinnaker services. \n\nCheck the logs looking for `retrofit error` or `<--- 500`",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 16,
        "y": 26,
        "w": 8,
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', '', '/', `requestHost`) AS metric, value FROM (SELECT time, `requestHost`, `statusCode`, sum(value) AS value FROM (SELECT time, `requestHost`, `statusCode`, d / dt AS value FROM (SELECT time, `requestHost`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestHost'] AS `requestHost`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'okhttp.requests' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND match(Attributes['status'], '^(?:(5xx|Unknown))$') GROUP BY time, series, `requestHost`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestHost`, `statusCode`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`statusCode`, '/', `requestHost`) AS metric, value FROM (SELECT time, `requestHost`, `statusCode`, sum(value) AS value FROM (SELECT time, `requestHost`, `statusCode`, d / dt AS value FROM (SELECT time, `requestHost`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestHost'] AS `requestHost`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'okhttp.requests' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] = '429' GROUP BY time, series, `requestHost`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestHost`, `statusCode`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "id": 16,
      "type": "row",
      "title": "JVM Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 34,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 17,
      "type": "timeseries",
      "title": "JVM Memory Usage",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 35,
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
          "rawSql": "SELECT time, `id` AS metric, value FROM (SELECT time, `id`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['id'] AS `id`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['area'] = 'heap' GROUP BY time, series, `id`) GROUP BY time, `id`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "decbytes",
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
      "id": 18,
      "type": "timeseries",
      "title": "JVM GC Average Pause Seconds",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 35,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, argMax(Sum, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'jvm.gc.pause' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`) GROUP BY time, `instance`) GROUP BY time, `instance`) AS a ALL INNER JOIN (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, argMax(Count, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'jvm.gc.pause' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`) GROUP BY time, `instance`) GROUP BY time, `instance`) AS b USING (time, `instance`)) ORDER BY time"
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
      "id": 19,
      "type": "timeseries",
      "title": "JVM GC Maximum Pause Seconds",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 35,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.gc.pause.max' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`) GROUP BY time, `instance`) ORDER BY time"
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
      "id": 20,
      "type": "timeseries",
      "title": "JVM Threads",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 35,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.threads.live' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`) ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
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
      "id": 21,
      "type": "row",
      "title": "Kubernetes Pod Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 43,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 22,
      "type": "timeseries",
      "title": "CPU",
      "description": "CPU Usage. Average is the average usage across all instances, max is the highest usage across all instances. As CPU Usage is a sampled metric it is best to view in relation to throttling percentage.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 44,
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
      "id": 23,
      "type": "timeseries",
      "title": "CPU Throttling",
      "description": "Percent of the time that the CPU is being throttled. Application may be getting throttled during bursty tasks but overall be well below its CPU limit. Throttling may significantly impact application performance.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 44,
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
      "id": 24,
      "type": "timeseries",
      "title": "Memory",
      "description": "Memory utilisation. Average is the average usage across all instaces, max is the highest usage across all instances.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 44,
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
      "id": 25,
      "type": "timeseries",
      "title": "Network",
      "description": "Average network ingress/egress for the $spinSvc pods.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 44,
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
