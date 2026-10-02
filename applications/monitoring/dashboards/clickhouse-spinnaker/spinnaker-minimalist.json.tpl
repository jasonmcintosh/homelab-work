{
  "title": "Spinnaker Minimalist (ClickHouse)",
  "uid": "ch-spinnaker-minimalist",
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
      "type": "timeseries",
      "title": "Resilience4J Open",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 0,
        "w": 24,
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
          "rawSql": "SELECT time, concat(`job`, '/', `metricGroup`, '(', `metricType`, ')') AS metric, value FROM (SELECT time, `job`, `metricGroup`, `metricType`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ServiceName AS `job`, Attributes['metricGroup'] AS `metricGroup`, Attributes['metricType'] AS `metricType`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'resilience4j.circuitbreaker.state' AND $__timeFilter(TimeUnix) AND Attributes['state'] = 'open' GROUP BY time, series, `job`, `metricGroup`, `metricType`) GROUP BY time, `job`, `metricGroup`, `metricType`) ORDER BY time"
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
      "id": 2,
      "type": "timeseries",
      "title": "Resilience4J Half-Open",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 8,
        "w": 24,
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
          "rawSql": "SELECT time, concat(`job`, ' /', `metricType`, '(', `metricGroup`, ')') AS metric, value FROM (SELECT time, `job`, `metricGroup`, `metricType`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ServiceName AS `job`, Attributes['metricGroup'] AS `metricGroup`, Attributes['metricType'] AS `metricType`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'resilience4j.circuitbreaker.state' AND $__timeFilter(TimeUnix) AND Attributes['state'] = 'half_open' GROUP BY time, series, `job`, `metricGroup`, `metricType`) GROUP BY time, `job`, `metricGroup`, `metricType`) ORDER BY time"
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
      "id": 3,
      "type": "timeseries",
      "title": "5xx Invocation Errors",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 16,
        "w": 24,
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
          "rawSql": "SELECT time, concat('Clouddriver/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:clouddriver.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Echo/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:echo.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Fiat/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:fiat.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "D",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Front50/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:front50.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "E",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Gate/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:gate.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "F",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Igor/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:igor.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "G",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Orca/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
        },
        {
          "refId": "H",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Rosco/', `statusCode`, '/', `controller`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`controller`, '^(?:(.*)Controller)$'), replaceRegexpOne(`controller`, '^(?:(.*)Controller)$', '\\\\1'), `controller`) AS `controller`, value FROM (SELECT time, `controller`, `statusCode`, sum(value) AS value FROM (SELECT time, `controller`, `statusCode`, d / dt AS value FROM (SELECT time, `controller`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:rosco.*)$') AND Attributes['status'] = '5xx' GROUP BY time, series, `controller`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `statusCode`)) ORDER BY time"
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
      "title": "Active Stages per Type/Platform (orca)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 24,
        "w": 24,
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
          "rawSql": "SELECT time, concat(`type`, '/', `cloudProvider`) AS metric, value FROM (SELECT time, `type`, `cloudProvider`, sum(value) AS value FROM (SELECT time, `cloudProvider`, `type`, d / dt AS value FROM (SELECT time, `cloudProvider`, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cloudProvider'] AS `cloudProvider`, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'stage.invocations' AND $__timeFilter(TimeUnix) GROUP BY time, series, `cloudProvider`, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `type`, `cloudProvider`) ORDER BY time"
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
      "title": "Completed Stages per Type/Platform (orca)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 32,
        "w": 24,
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
          "rawSql": "SELECT time, concat(`cloudProvider`, ' :: ', `type`) AS metric, value FROM (SELECT time, `cloudProvider`, `type`, sum(value) AS value FROM (SELECT time, `cloudProvider`, `type`, d / dt AS value FROM (SELECT time, `cloudProvider`, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cloudProvider'] AS `cloudProvider`, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'stage.invocations' AND $__timeFilter(TimeUnix) GROUP BY time, series, `cloudProvider`, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cloudProvider`, `type`) ORDER BY time"
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
      "title": "Stage Duration (log2) per Platform (orca)",
      "description": "Not all AWS stages have \"cloudProvider\" label. Override missing options to \"aws(override)\"",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 40,
        "w": 24,
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
          "rawSql": "SELECT time, `cloudProvider` AS metric, value FROM (SELECT time, `cloudProvider`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `cloudProvider`, sum(value) AS value FROM (SELECT time, `cloudProvider`, sum(value) AS value FROM (SELECT time, `cloudProvider`, d / dt AS value FROM (SELECT time, `cloudProvider`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cloudProvider'] AS `cloudProvider`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'stage.invocations.duration' AND $__timeFilter(TimeUnix) GROUP BY time, series, `cloudProvider`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cloudProvider`) GROUP BY time, `cloudProvider`) AS a ALL INNER JOIN (SELECT time, `cloudProvider`, sum(value) AS value FROM (SELECT time, `cloudProvider`, sum(value) AS value FROM (SELECT time, `cloudProvider`, d / dt AS value FROM (SELECT time, `cloudProvider`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cloudProvider'] AS `cloudProvider`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'stage.invocations.duration' AND $__timeFilter(TimeUnix) GROUP BY time, series, `cloudProvider`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cloudProvider`) GROUP BY time, `cloudProvider`) AS b USING (time, `cloudProvider`)) ORDER BY time"
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
      "id": 7,
      "type": "timeseries",
      "title": "Pipelines Triggered (echo)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 48,
        "w": 24,
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
          "rawSql": "SELECT time, concat(`application`, ' :: ', `monitor`) AS metric, value FROM (SELECT time, `application`, `monitor`, sum(value) AS value FROM (SELECT time, `application`, `monitor`, d / dt AS value FROM (SELECT time, `application`, `monitor`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['application'] AS `application`, Attributes['monitor'] AS `monitor`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'pipelines.triggered' AND $__timeFilter(TimeUnix) GROUP BY time, series, `application`, `monitor`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `application`, `monitor`) ORDER BY time"
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
      "title": "Active Bakes (rosco)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 56,
        "w": 24,
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
          "rawSql": "SELECT time, 'Active' AS metric, value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'bakesActive' AND $__timeFilter(TimeUnix) GROUP BY time, series) ORDER BY time"
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
      "title": "Bake Request and Completion Rates (rosco)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 64,
        "w": 24,
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
          "rawSql": "SELECT time, concat('Requested/', `flavor`) AS metric, value FROM (SELECT time, `flavor`, sum(value) AS value FROM (SELECT time, `flavor`, d / dt AS value FROM (SELECT time, `flavor`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['flavor'] AS `flavor`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'bakesRequested' AND $__timeFilter(TimeUnix) GROUP BY time, series, `flavor`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `flavor`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Failure/', `region`) AS metric, value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, d / dt AS value FROM (SELECT time, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND Attributes['success'] = 'false' GROUP BY time, series, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat('Success/', `region`) AS metric, value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, d / dt AS value FROM (SELECT time, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'bakesCompleted' AND $__timeFilter(TimeUnix) AND Attributes['success'] = 'true' GROUP BY time, series, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`) ORDER BY time"
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
      "id": 10,
      "type": "timeseries",
      "title": "Item Cache Size (front50)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 72,
        "w": 24,
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
          "rawSql": "SELECT time, `objectType` AS metric, value FROM (SELECT time, `objectType`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['objectType'] AS `objectType`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'storageServiceSupport.cacheSize' AND $__timeFilter(TimeUnix) GROUP BY time, series, `objectType`) GROUP BY time, `objectType`) ORDER BY time"
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
      "title": "Execution Count (clouddriver)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 80,
        "w": 24,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) ORDER BY time"
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
      "title": "Execution Latency (clouddriver)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 88,
        "w": 24,
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
          "rawSql": "SELECT time, `instance` AS metric, value FROM (SELECT time, `instance`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) GROUP BY time, `instance`) AS a ALL INNER JOIN (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, sum(value) AS value FROM (SELECT time, `instance`, d / dt AS value FROM (SELECT time, `instance`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'executionTime' AND $__timeFilter(TimeUnix) GROUP BY time, series, `instance`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`) GROUP BY time, `instance`) AS b USING (time, `instance`)) ORDER BY time"
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
    }
  ]
}
