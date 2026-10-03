{
  "title": "Clouddriver (ClickHouse)",
  "uid": "ch-spinnaker-clouddriver",
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
      "url": "https://github.com/spinnaker/clouddriver"
    }
  ],
  "templating": {
    "list": [
      {
        "name": "spinSvc",
        "label": "",
        "type": "custom",
        "query": "clouddriver",
        "current": {
          "text": "clouddriver",
          "value": "clouddriver"
        },
        "options": [
          {
            "text": "clouddriver",
            "value": "clouddriver"
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
        "definition": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND match(ServiceName, '^(?:.*clouddriver.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE MetricName = 'jvm.memory.used' AND match(ServiceName, '^(?:.*clouddriver.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
      },
      {
        "name": "Account",
        "label": "Account",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT Attributes['account'] FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND ServiceName IN ($job) AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT Attributes['account'] FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND ServiceName IN ($job) AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "name": "Platform",
        "label": "",
        "type": "custom",
        "query": "google,aws,kubernetes,docker,appengine,dcos",
        "current": {
          "text": "All",
          "value": "$__all"
        },
        "options": [
          {
            "text": "All",
            "value": "$__all"
          },
          {
            "text": "google",
            "value": "google"
          },
          {
            "text": "aws",
            "value": "aws"
          },
          {
            "text": "kubernetes",
            "value": "kubernetes"
          },
          {
            "text": "docker",
            "value": "docker"
          },
          {
            "text": "appengine",
            "value": "appengine"
          },
          {
            "text": "dcos",
            "value": "dcos"
          }
        ],
        "multi": true,
        "includeAll": true,
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
        "content": "This service is the main integration point for Spinnaker cloud providers like AWS, Azure, CloudFoundry, GCP, Kubernetes, etc."
      }
    },
    {
      "id": 3,
      "type": "row",
      "title": "Errors",
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
      "title": "$Account 5xx Errors (clouddriver, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `controller`, '/', `method`) AS metric, value FROM (SELECT time, `controller`, `method`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `method`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `method`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['status'] = '5xx' AND Attributes['account'] IN ($Account) GROUP BY time, series, `controller`, `method`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`, `statusCode`) ORDER BY time"
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
      "title": "Validation Errors",
      "description": "",
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
          "rawSql": "SELECT time, `operation` AS metric, value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'validationErrors' AND $__timeFilter(TimeUnix) GROUP BY time, series, `operation`) ORDER BY time"
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
      "type": "row",
      "title": "Operations and Tasks",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 18,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 7,
      "type": "timeseries",
      "title": "$Account Controller Invocation by Method (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 19,
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
          "rawSql": "SELECT time, concat(`controller`, '/', `method`) AS metric, value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, d / dt AS value FROM (SELECT time, `controller`, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['account'] IN ($Account) GROUP BY time, series, `controller`, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`) ORDER BY time"
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
      "id": 8,
      "type": "timeseries",
      "title": "Operation Failures by Operation (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 19,
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
          "rawSql": "SELECT time, `OperationType` AS metric, value FROM (SELECT time, `OperationType`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, d / dt AS value FROM (SELECT time, `OperationType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['OperationType'] AS `OperationType`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'operations' AND $__timeFilter(TimeUnix) AND Attributes['success'] != 'true' GROUP BY time, series, `OperationType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `OperationType`) GROUP BY time, `OperationType`) AS a ALL INNER JOIN (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, d / dt AS value FROM (SELECT time, `OperationType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['OperationType'] AS `OperationType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'operations' AND $__timeFilter(TimeUnix) GROUP BY time, series, `OperationType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `OperationType`) GROUP BY time, `OperationType`) AS b USING (time, `OperationType`)) ORDER BY time"
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
      "id": 9,
      "type": "timeseries",
      "title": "$Account Controller Invocation Latency by Method (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 19,
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
          "rawSql": "SELECT time, concat(`controller`, '/', `method`) AS metric, value FROM (SELECT time, `controller`, `method`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, d / dt AS value FROM (SELECT time, `controller`, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['account'] IN ($Account) GROUP BY time, series, `controller`, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`) GROUP BY time, `controller`, `method`) AS a ALL INNER JOIN (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, sum(value) AS value FROM (SELECT time, `controller`, `method`, d / dt AS value FROM (SELECT time, `controller`, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['method'] AS `method`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['account'] IN ($Account) GROUP BY time, series, `controller`, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `method`) GROUP BY time, `controller`, `method`) AS b USING (time, `controller`, `method`)) ORDER BY time"
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
      "id": 10,
      "type": "timeseries",
      "title": "Tasks per Instance (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 19,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'tasks' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) ORDER BY time"
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
      "title": "Operations by Operation (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 27,
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
          "rawSql": "SELECT time, `OperationType` AS metric, value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, d / dt AS value FROM (SELECT time, `OperationType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['OperationType'] AS `OperationType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'operations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `OperationType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `OperationType`) ORDER BY time"
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
      "id": 12,
      "type": "timeseries",
      "title": "Execution Count by Instance (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 27,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) ORDER BY time"
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
      "title": "Operation Time by Operation (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 27,
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
          "rawSql": "SELECT time, `OperationType` AS metric, value FROM (SELECT time, `OperationType`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, d / dt AS value FROM (SELECT time, `OperationType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['OperationType'] AS `OperationType`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'operations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `OperationType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `OperationType`) GROUP BY time, `OperationType`) AS a ALL INNER JOIN (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, sum(value) AS value FROM (SELECT time, `OperationType`, d / dt AS value FROM (SELECT time, `OperationType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['OperationType'] AS `OperationType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'operations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `OperationType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `OperationType`) GROUP BY time, `OperationType`) AS b USING (time, `OperationType`)) ORDER BY time"
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
      "id": 14,
      "type": "timeseries",
      "title": "Execution Latency by Instance (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 27,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) GROUP BY time, `instance`) AS a ALL INNER JOIN (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) GROUP BY time, `instance`) AS b USING (time, `instance`)) ORDER BY time"
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
      "id": 15,
      "type": "timeseries",
      "title": "On Demand Reads by Type (clouddriver, $Instance, $Platform)",
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
          "rawSql": "SELECT time, `onDemandType` AS metric, value FROM (SELECT time, `onDemandType`, sum(value) AS value FROM (SELECT time, `onDemandType`, d / dt AS value FROM (SELECT time, `onDemandType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['onDemandType'] AS `onDemandType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'onDemand.read' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND arrayExists(x -> match(Attributes['providerName'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `onDemandType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `onDemandType`) ORDER BY time"
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
      "id": 16,
      "type": "timeseries",
      "title": "Cache Agent Execution by Account (clouddriver, $Instance, $Platform)",
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
          "rawSql": "SELECT time, concat(`provider`, ' :: ', `account`) AS metric, value FROM (SELECT time, `provider`, `account`, sum(value) AS value FROM (SELECT time, `agent`, `account`, if(match(`agent`, '^(?:^([A-Za-z]+).*)$'), replaceRegexpOne(`agent`, '^(?:^([A-Za-z]+).*)$', '\\\\1'), '') AS `provider`, value FROM (SELECT time, `agent`, if(match(`agent`, '^(?:^[A-Za-z]+/([A-Za-z0-9-]+).*)$'), replaceRegexpOne(`agent`, '^(?:^[A-Za-z]+/([A-Za-z0-9-]+).*)$', '\\\\1'), '') AS `account`, value FROM (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, d / dt AS value FROM (SELECT time, `agent`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['agent'] AS `agent`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND arrayExists(x -> match(Attributes['agent'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `agent`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `agent`))) GROUP BY time, `provider`, `account`) ORDER BY time"
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
      "id": 17,
      "type": "timeseries",
      "title": "On Demand Read Latency by Type (clouddriver, $Instance, $Platform)",
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
          "rawSql": "SELECT time, `onDemandType` AS metric, value FROM (SELECT time, `onDemandType`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `onDemandType`, sum(value) AS value FROM (SELECT time, `onDemandType`, sum(value) AS value FROM (SELECT time, `onDemandType`, d / dt AS value FROM (SELECT time, `onDemandType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['onDemandType'] AS `onDemandType`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'onDemand.read' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND arrayExists(x -> match(Attributes['providerName'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `onDemandType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `onDemandType`) GROUP BY time, `onDemandType`) AS a ALL INNER JOIN (SELECT time, `onDemandType`, sum(value) AS value FROM (SELECT time, `onDemandType`, sum(value) AS value FROM (SELECT time, `onDemandType`, d / dt AS value FROM (SELECT time, `onDemandType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['onDemandType'] AS `onDemandType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'onDemand.read' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND arrayExists(x -> match(Attributes['providerName'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `onDemandType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `onDemandType`) GROUP BY time, `onDemandType`) AS b USING (time, `onDemandType`)) ORDER BY time"
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
      "id": 18,
      "type": "row",
      "title": "SQL Caching",
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
      "id": 19,
      "type": "timeseries",
      "title": "Cache Agent Execution Latency by Account (clouddriver, $Instance, $Platform)",
      "description": "",
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
          "rawSql": "SELECT time, concat(`provider`, ' :: ', `account`) AS metric, value FROM (SELECT time, `provider`, `account`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `provider`, `account`, sum(value) AS value FROM (SELECT time, `provider`, `account`, sum(value) AS value FROM (SELECT time, `agent`, `account`, if(match(`agent`, '^(?:^([A-Za-z]+).*)$'), replaceRegexpOne(`agent`, '^(?:^([A-Za-z]+).*)$', '\\\\1'), '') AS `provider`, value FROM (SELECT time, `agent`, if(match(`agent`, '^(?:^[A-Za-z]+/([A-Za-z0-9-]+).*)$'), replaceRegexpOne(`agent`, '^(?:^[A-Za-z]+/([A-Za-z0-9-]+).*)$', '\\\\1'), '') AS `account`, value FROM (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, d / dt AS value FROM (SELECT time, `agent`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['agent'] AS `agent`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND arrayExists(x -> match(Attributes['agent'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `agent`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `agent`))) GROUP BY time, `provider`, `account`) GROUP BY time, `provider`, `account`) AS a ALL INNER JOIN (SELECT time, `provider`, `account`, sum(value) AS value FROM (SELECT time, `provider`, `account`, sum(value) AS value FROM (SELECT time, `agent`, `account`, if(match(`agent`, '^(?:^([A-Za-z]+).*)$'), replaceRegexpOne(`agent`, '^(?:^([A-Za-z]+).*)$', '\\\\1'), '') AS `provider`, value FROM (SELECT time, `agent`, if(match(`agent`, '^(?:^[A-Za-z]+/([A-Za-z0-9-]+).*)$'), replaceRegexpOne(`agent`, '^(?:^[A-Za-z]+/([A-Za-z0-9-]+).*)$', '\\\\1'), '') AS `account`, value FROM (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, d / dt AS value FROM (SELECT time, `agent`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['agent'] AS `agent`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND arrayExists(x -> match(Attributes['agent'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `agent`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `agent`))) GROUP BY time, `provider`, `account`) GROUP BY time, `provider`, `account`) AS b USING (time, `provider`, `account`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'TBC' AS metric, value FROM (SELECT time, `agent`, if(match(`agent`, '^(?:(?:.*(?:Amazon|Appengine|Google|Kubernetes|Dcos|/)([^/]*)CachingAgent.*))$'), replaceRegexpOne(`agent`, '^(?:(?:.*(?:Amazon|Appengine|Google|Kubernetes|Dcos|/)([^/]*)CachingAgent.*))$', '\\\\1'), '') AS `itemType`, value FROM (SELECT time, `agent`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, d / dt AS value FROM (SELECT time, `agent`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['agent'] AS `agent`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['agent'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `agent`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `agent`) GROUP BY time, `agent`) AS a ALL INNER JOIN (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, sum(value) AS value FROM (SELECT time, `agent`, d / dt AS value FROM (SELECT time, `agent`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['agent'] AS `agent`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['agent'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `agent`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `agent`) GROUP BY time, `agent`) AS b USING (time, `agent`))) ORDER BY time"
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
      "title": "CATS Relationships Requested by Platform (clouddriver, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.get.relationshipsRequested' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.get.relationshipsRequested' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 21,
      "type": "timeseries",
      "title": "CATS Relationships Requested by Type (clouddriver, $Instance, $Platform)",
      "description": "",
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.get.relationshipsRequested' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 22,
      "type": "timeseries",
      "title": "CATS Items Requested by Platform (clouddriver, $Instance)",
      "description": "",
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.get.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.get.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 23,
      "type": "timeseries",
      "title": "CATS Items Requested by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 52,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.get.itemCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 24,
      "type": "timeseries",
      "title": "CATS Relationships Written by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 52,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.merge.relationshipCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.merge.relationshipCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 25,
      "type": "timeseries",
      "title": "CATS Relationships Written by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 52,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.merge.relationshipCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 26,
      "type": "timeseries",
      "title": "CATS Items Written by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 52,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.merge.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.merge.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 27,
      "type": "timeseries",
      "title": "CATS Items Written by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 60,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.merge.itemCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 28,
      "type": "timeseries",
      "title": "CATS Items Deleted by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 60,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 29,
      "type": "timeseries",
      "title": "CATS Items Deleted by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 60,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.sqlCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 30,
      "type": "row",
      "title": "Redis Caching",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 68,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 31,
      "type": "timeseries",
      "title": "CATS Keys Requested by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 69,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.get.keysRequested' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.get.keysRequested' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 32,
      "type": "timeseries",
      "title": "CATS Keys Requested by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 69,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.get.keysRequested' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 33,
      "type": "timeseries",
      "title": "CATS Items Requested by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 69,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.get.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.get.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 34,
      "type": "timeseries",
      "title": "CATS Items Requested by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 69,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.get.itemCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 35,
      "type": "timeseries",
      "title": "CATS Keys Written by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 77,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.merge.keysWritten' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.merge.keysWritten' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 36,
      "type": "timeseries",
      "title": "CATS Keys Written by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 77,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.merge.keysWritten' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 37,
      "type": "timeseries",
      "title": "CATS Items Written by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 77,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.merge.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('prefix=', `prefix`) AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.merge.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 38,
      "type": "timeseries",
      "title": "CATS Items Written by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 77,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.merge.itemCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 39,
      "type": "timeseries",
      "title": "CATS Keys Deleted by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 85,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 40,
      "type": "timeseries",
      "title": "CATS Keys Deleted by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 85,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.evict.keysDeleted' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 41,
      "type": "timeseries",
      "title": "CATS Items Deleted by Platform (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 85,
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
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$'), replaceRegexpOne(`prefix`, '^(?:.*.clouddriver.([^\\\\.]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `platform` AS metric, value FROM (SELECT time, `prefix`, if(match(`prefix`, '^(?:([^\\\\./]*).*)$'), replaceRegexpOne(`prefix`, '^(?:([^\\\\./]*).*)$', '\\\\1'), '') AS `platform`, value FROM (SELECT time, `prefix`, sum(value) AS value FROM (SELECT time, `prefix`, d / dt AS value FROM (SELECT time, `prefix`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['prefix'] AS `prefix`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND NOT match(Attributes['prefix'], '^(?:com.netflix.*)$') AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `prefix`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `prefix`)) ORDER BY time"
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
      "id": 42,
      "type": "timeseries",
      "title": "CATS Items Deleted by Type (clouddriver, $Instance, $Platform)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 85,
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
          "rawSql": "SELECT time, `type` AS metric, value FROM (SELECT time, `type`, sum(value) AS value FROM (SELECT time, `type`, d / dt AS value FROM (SELECT time, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'cats.redisCache.evict.itemCount' AND $__timeFilter(TimeUnix) AND arrayExists(x -> match(Attributes['prefix'], concat('^(?:.*', x, '.*)$')), [$Platform]) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`) ORDER BY time"
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
      "id": 43,
      "type": "row",
      "title": "TODO - Google Operations - Confirm metric names",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 93,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 44,
      "type": "text",
      "title": "Google Operation Failures (clouddriver, $Instance)",
      "gridPos": {
        "x": 0,
        "y": 94,
        "w": 6,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "Not available from ClickHouse.\n\n\n\nPrometheus original: ``"
      }
    },
    {
      "id": 45,
      "type": "timeseries",
      "title": "Google Operation Wait Until Done Time (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 94,
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
          "rawSql": "SELECT time, concat(`scope`, '/', `basePhase`) AS metric, value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, d / dt AS value FROM (SELECT time, `basePhase`, `scope`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['status'] != 'DONE' GROUP BY time, series, `basePhase`, `scope`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`, `scope`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`scope`, '/', `basePhase`) AS metric, value FROM (SELECT time, `basePhase`, `scope`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, d / dt AS value FROM (SELECT time, `basePhase`, `scope`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `basePhase`, `scope`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`, `scope`) GROUP BY time, `basePhase`, `scope`) AS a ALL INNER JOIN (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, d / dt AS value FROM (SELECT time, `basePhase`, `scope`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `basePhase`, `scope`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`, `scope`) GROUP BY time, `basePhase`, `scope`) AS b USING (time, `basePhase`, `scope`)) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`scope`, '/', `basePhase`) AS metric, value FROM (SELECT time, `basePhase`, `scope`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `basePhase`, `scope`) GROUP BY time, `basePhase`, `scope`) GROUP BY time, `basePhase`, `scope`) AS a ALL INNER JOIN (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `basePhase`, `scope`) GROUP BY time, `basePhase`, `scope`) GROUP BY time, `basePhase`, `scope`) AS b USING (time, `basePhase`, `scope`)) ORDER BY time"
        },
        {
          "refId": "D",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'value' AS metric, value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) ORDER BY time"
        },
        {
          "refId": "E",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`scope`, '/', `basePhase`) AS metric, value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'clouddriver.google.operationWaitRequests' AND $__timeFilter(TimeUnix) GROUP BY time, series, `basePhase`, `scope`) ORDER BY time"
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
      "id": 46,
      "type": "text",
      "title": "Google Operations Started (clouddriver, $Instance)",
      "gridPos": {
        "x": 12,
        "y": 94,
        "w": 6,
        "h": 8
      },
      "options": {
        "mode": "markdown",
        "content": "Not available from ClickHouse.\n\n\n\nPrometheus original: ``"
      }
    },
    {
      "id": 47,
      "type": "timeseries",
      "title": "Google Operation Success (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 94,
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
          "rawSql": "SELECT time, `basePhase` AS metric, value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['status'] = 'DONE' GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) ORDER BY time"
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
      "id": 48,
      "type": "row",
      "title": "Amazon Operations",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 102,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 49,
      "type": "timeseries",
      "title": "Amazon Client Rate Limiting by ClientType (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 103,
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
          "rawSql": "SELECT time, `clientType` AS metric, value FROM (SELECT time, `clientType`, avg(value) AS value FROM (SELECT time, `clientType`, d / dt AS value FROM (SELECT time, `clientType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['clientType'] AS `clientType`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'amazonClientProvider.rateLimitDelayMil' AND $__timeFilter(TimeUnix) GROUP BY time, series, `clientType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `clientType`) ORDER BY time"
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
      "id": 50,
      "type": "timeseries",
      "title": "$Account Cache Drift by Region/Agent (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 103,
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
          "rawSql": "SELECT time, concat(`account`, '/', `region`, '/', `agent`) AS metric, value FROM (SELECT time, `account`, `region`, if(match(`agent`, '^(?:(.*)CachingAgent)$'), replaceRegexpOne(`agent`, '^(?:(.*)CachingAgent)$', '\\\\1'), `agent`) AS `agent`, value FROM (SELECT time, `account`, `agent`, `region`, avg(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['account'] AS `account`, Attributes['agent'] AS `agent`, Attributes['region'] AS `region`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'cache.drift' AND $__timeFilter(TimeUnix) AND Attributes['account'] IN ($Account) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `account`, `agent`, `region`) GROUP BY time, `account`, `agent`, `region`)) ORDER BY time"
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
      "id": 51,
      "type": "row",
      "title": "HTTP Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 111,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 52,
      "type": "timeseries",
      "title": "Inbound Request Rate by Method",
      "description": "Inbound HTTP requests. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 112,
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
      "id": 53,
      "type": "timeseries",
      "title": "Inbound Request Latency by Method",
      "description": "Inbound HTTP request latencies. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 8,
        "y": 112,
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
      "id": 54,
      "type": "timeseries",
      "title": "Inbound Request Errors by Method",
      "description": "Inbound HTTP request errors. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 16,
        "y": 112,
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
      "id": 55,
      "type": "timeseries",
      "title": "Outbound Request Rate",
      "description": "Rate of outbound http requests to other Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 120,
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
      "id": 56,
      "type": "timeseries",
      "title": "Outbound Request Latency",
      "description": "Latency of outbound http requests to other Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 8,
        "y": 120,
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
      "id": 57,
      "type": "timeseries",
      "title": "Outbound Request Error Rate",
      "description": "Rate of outbound http request errors when calling other Spinnaker services. \n\nCheck the logs looking for `retrofit error` or `<--- 500`",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 16,
        "y": 120,
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
      "id": 58,
      "type": "row",
      "title": "JVM Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 128,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 59,
      "type": "timeseries",
      "title": "JVM Memory Usage",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 129,
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
      "id": 60,
      "type": "timeseries",
      "title": "JVM GC Average Pause Seconds",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 129,
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
      "id": 61,
      "type": "timeseries",
      "title": "JVM GC Maximum Pause Seconds",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 129,
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
      "id": 62,
      "type": "timeseries",
      "title": "JVM Threads",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 129,
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
      "id": 63,
      "type": "row",
      "title": "Kubernetes Pod Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 137,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 64,
      "type": "timeseries",
      "title": "CPU",
      "description": "CPU Usage. Average is the average usage across all instances, max is the highest usage across all instances. As CPU Usage is a sampled metric it is best to view in relation to throttling percentage.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 138,
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
          "rawSql": "SELECT time, 'avg' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_usage_seconds_total' AND $__timeFilter(TimeUnix) AND match(Attributes['container'], '^(?:$spinSvc)$') GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'max' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_usage_seconds_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] = '$spinSvc' GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
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
      "id": 65,
      "type": "timeseries",
      "title": "CPU Throttling",
      "description": "Percent of the time that the CPU is being throttled. Application may be getting throttled during bursty tasks but overall be well below its CPU limit. Throttling may significantly impact application performance.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 138,
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
          "rawSql": "SELECT time, `pod` AS metric, value FROM (SELECT time, `pod`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_cfs_throttled_periods_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] = '$spinSvc' GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) AS a ALL INNER JOIN (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_cpu_cfs_periods_total' AND $__timeFilter(TimeUnix) AND Attributes['container'] = '$spinSvc' GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) AS b USING (time, `pod`)) ORDER BY time"
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
      "id": 66,
      "type": "timeseries",
      "title": "Memory",
      "description": "Memory utilisation. Average is the average usage across all instaces, max is the highest usage across all instances.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 138,
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
          "rawSql": "SELECT time, 'avg' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'container_memory_working_set_bytes' AND $__timeFilter(TimeUnix) AND Attributes['container'] = '$spinSvc' GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'max' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'container_memory_working_set_bytes' AND $__timeFilter(TimeUnix) AND Attributes['container'] = '$spinSvc' GROUP BY time, series) GROUP BY time) ORDER BY time"
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
      "id": 67,
      "type": "timeseries",
      "title": "Network",
      "description": "Average network ingress/egress for the $spinSvc pods.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 138,
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
          "rawSql": "SELECT time, 'receive' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_network_receive_bytes_total' AND $__timeFilter(TimeUnix) AND match(Attributes['pod'], '^(?:spin-$spinSvc.*)$') GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'transmit' AS metric, value FROM (SELECT time, avg(value) AS value FROM (SELECT time, `pod`, sum(value) AS value FROM (SELECT time, `pod`, d / dt AS value FROM (SELECT time, `pod`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['pod'] AS `pod`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'container_network_transmit_bytes_total' AND $__timeFilter(TimeUnix) AND match(Attributes['pod'], '^(?:spin-$spinSvc.*)$') GROUP BY time, series, `pod`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `pod`) GROUP BY time) ORDER BY time"
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
