{
  "title": "Spinnaker GCP Platform (ClickHouse)",
  "uid": "ch-spinnaker-gcp-platform",
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
    "list": [
      {
        "name": "GcpRegion",
        "label": "GcpRegion",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT Attributes['region'] FROM otel.otel_metrics_histogram WHERE MetricName = 'clouddriver.google.api.' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT Attributes['region'] FROM otel.otel_metrics_histogram WHERE MetricName = 'clouddriver.google.api.' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "name": "ClouddriverInstance",
        "label": "ClouddriverInstance",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_histogram WHERE MetricName = 'clouddriver.google.api.' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_histogram WHERE MetricName = 'clouddriver.google.api.' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "name": "Front50Instance",
        "label": "Front50Instance",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_histogram WHERE MetricName = 'front50.google.storage.invocation.' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_histogram WHERE MetricName = 'front50.google.storage.invocation.' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
      "title": "API Errors",
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
      "type": "timeseries",
      "title": "GCP API Failures by Resource (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `resource`) AS metric, value FROM (SELECT time, `resource`, `statusCode`, sum(value) AS value FROM (SELECT time, `api`, `statusCode`, if(match(`api`, '^(?:compute.(.*)\\\\..*)$'), replaceRegexpOne(`api`, '^(?:compute.(.*)\\\\..*)$', '\\\\1'), '') AS `resource`, value FROM (SELECT time, `api`, `statusCode`, d / dt AS value FROM (SELECT time, `api`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, Attributes['statusCode'] AS `statusCode`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['status'] != '2xx' GROUP BY time, series, `api`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `resource`, `statusCode`) ORDER BY time"
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
      "title": "GCP API Failures by Region (clouddriver, $ClouddriverInstance)",
      "description": "",
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `region`) AS metric, value FROM (SELECT time, `region`, `statusCode`, sum(value) AS value FROM (SELECT time, `region`, `statusCode`, d / dt AS value FROM (SELECT time, `region`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, Attributes['statusCode'] AS `statusCode`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['status'] != '2xx' AND Attributes['scope'] = 'regional' GROUP BY time, series, `region`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`, `statusCode`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`statusCode`, '/', `zoneRegion`, '+') AS metric, value FROM (SELECT time, `zoneRegion`, `statusCode`, sum(value) AS value FROM (SELECT time, `statusCode`, `zone`, if(match(`zone`, '^(?:(.*)-.)$'), replaceRegexpOne(`zone`, '^(?:(.*)-.)$', '\\\\1'), '') AS `zoneRegion`, value FROM (SELECT time, `statusCode`, `zone`, d / dt AS value FROM (SELECT time, `statusCode`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['statusCode'] AS `statusCode`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['status'] != '2xx' AND Attributes['scope'] = 'zonal' GROUP BY time, series, `statusCode`, `zone`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `zoneRegion`, `statusCode`) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`statusCode`, '/global') AS metric, value FROM (SELECT time, `zone`, `statusCode`, sum(value) AS value FROM (SELECT time, `statusCode`, `zone`, d / dt AS value FROM (SELECT time, `statusCode`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['statusCode'] AS `statusCode`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['status'] != '2xx' AND Attributes['scope'] = 'global' GROUP BY time, series, `statusCode`, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `zone`, `statusCode`) ORDER BY time"
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
      "title": "Google Storage Failures By Method (front50, $Front50Instance)",
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `method`) AS metric, value FROM (SELECT time, `method`, `statusCode`, sum(value) AS value FROM (SELECT time, `method`, `statusCode`, d / dt AS value FROM (SELECT time, `method`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['method'] AS `method`, Attributes['statusCode'] AS `statusCode`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'front50.google.storage.invocation.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Front50Instance) AND Attributes['status'] != '2xx' GROUP BY time, series, `method`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `method`, `statusCode`) ORDER BY time"
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
      "title": "Google Storage Retry Failures by Method (front50, $Front50Instance)",
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `method`) AS metric, value FROM (SELECT time, `method`, `statusCode`, sum(value) AS value FROM (SELECT time, `method`, `statusCode`, d / dt AS value FROM (SELECT time, `method`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['method'] AS `method`, Attributes['statusCode'] AS `statusCode`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'front50.google.storage.invocation.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Front50Instance) AND Attributes['status'] != '2xx' GROUP BY time, series, `method`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `method`, `statusCode`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `action` AS metric, value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, d / dt AS value FROM (SELECT time, `action`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'front50.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Front50Instance) AND Attributes['success'] != 'true' GROUP BY time, series, `action`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`) ORDER BY time"
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
      "title": "API Call Summary",
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
      "id": 7,
      "type": "timeseries",
      "title": "GCP API Calls by Resource (clouddriver, $ClouddriverInstance)",
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
          "rawSql": "SELECT time, `resource` AS metric, value FROM (SELECT time, `resource`, sum(value) AS value FROM (SELECT time, `api`, if(match(`api`, '^(?:compute.(.*)\\\\..*)$'), replaceRegexpOne(`api`, '^(?:compute.(.*)\\\\..*)$', '\\\\1'), '') AS `resource`, value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `resource`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, `resource` AS metric, value FROM (SELECT time, `resource`, `status`, `statusCode`, sum(value) AS value FROM (SELECT time, `api`, `status`, `statusCode`, if(match(`api`, '^(?:compute.(.*)\\\\..*)$'), replaceRegexpOne(`api`, '^(?:compute.(.*)\\\\..*)$', '\\\\1'), '') AS `resource`, value FROM (SELECT time, `api`, `status`, `statusCode`, d / dt AS value FROM (SELECT time, `api`, `status`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, Attributes['status'] AS `status`, Attributes['statusCode'] AS `statusCode`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) GROUP BY time, series, `api`, `status`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `resource`, `status`, `statusCode`) ORDER BY time"
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
      "title": "GCP API Calls by Region (clouddriver, $ClouddriverInstance)",
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
          "rawSql": "SELECT time, `region` AS metric, value FROM (SELECT time, `region`, sum(value) AS value FROM (SELECT time, `region`, d / dt AS value FROM (SELECT time, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['region'] AS `region`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' GROUP BY time, series, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`zoneRegion`, '+') AS metric, value FROM (SELECT time, `zoneRegion`, sum(value) AS value FROM (SELECT time, `zone`, if(match(`zone`, '^(?:(.*)-.)$'), replaceRegexpOne(`zone`, '^(?:(.*)-.)$', '\\\\1'), '') AS `zoneRegion`, value FROM (SELECT time, `zone`, d / dt AS value FROM (SELECT time, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' GROUP BY time, series, `zone`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `zoneRegion`) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'global' AS metric, value FROM (SELECT time, `zone`, sum(value) AS value FROM (SELECT time, `zone`, d / dt AS value FROM (SELECT time, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `zone`) ORDER BY time"
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
      "type": "row",
      "title": "Global API Calls",
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
      "id": 10,
      "type": "timeseries",
      "title": "Global GCP API Calls (clouddriver, $ClouddriverInstance)",
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
          "rawSql": "SELECT time, `api` AS metric, value FROM (SELECT time, if(match(`api`, '^(?:compute.(.*))$'), replaceRegexpOne(`api`, '^(?:compute.(.*))$', '\\\\1'), `api`) AS `api`, value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`)) ORDER BY time"
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
      "title": "Global GCP API Latency (clouddriver, $ClouddriverInstance)",
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
          "rawSql": "SELECT time, `api` AS metric, value FROM (SELECT time, if(match(`api`, '^(?:compute.(.*))$'), replaceRegexpOne(`api`, '^(?:compute.(.*))$', '\\\\1'), `api`) AS `api`, value FROM (SELECT time, `api`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`) GROUP BY time, `api`) AS a ALL INNER JOIN (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`) GROUP BY time, `api`) AS b USING (time, `api`))) ORDER BY time"
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
      "type": "row",
      "title": "Regional API Calls",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 27,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 13,
      "type": "timeseries",
      "title": "Regional GCP API Calls in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 28,
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
          "rawSql": "SELECT time, `api` AS metric, value FROM (SELECT time, if(match(`api`, '^(?:compute.(.*))$'), replaceRegexpOne(`api`, '^(?:compute.(.*))$', '\\\\1'), `api`) AS `api`, value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`)) ORDER BY time"
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
      "title": "Regional GCP API Latency in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 28,
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
          "rawSql": "SELECT time, `api` AS metric, value FROM (SELECT time, if(match(`api`, '^(?:compute.(.*))$'), replaceRegexpOne(`api`, '^(?:compute.(.*))$', '\\\\1'), `api`) AS `api`, value FROM (SELECT time, `api`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`) GROUP BY time, `api`) AS a ALL INNER JOIN (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, sum(value) AS value FROM (SELECT time, `api`, d / dt AS value FROM (SELECT time, `api`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `api`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`) GROUP BY time, `api`) AS b USING (time, `api`))) ORDER BY time"
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
      "type": "row",
      "title": "Zonal API Calls",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 36,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 16,
      "type": "timeseries",
      "title": "Zonal GCP API in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 37,
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
          "rawSql": "SELECT time, concat(`api`, '/', `cell`) AS metric, value FROM (SELECT time, `zone`, `api`, if(match(`zone`, '^(?:.*-(.))$'), replaceRegexpOne(`zone`, '^(?:.*-(.))$', '\\\\1'), '') AS `cell`, value FROM (SELECT time, `zone`, if(match(`api`, '^(?:compute.(.*))$'), replaceRegexpOne(`api`, '^(?:compute.(.*))$', '\\\\1'), `api`) AS `api`, value FROM (SELECT time, `zone`, `api`, sum(value) AS value FROM (SELECT time, `api`, `zone`, d / dt AS value FROM (SELECT time, `api`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `api`, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `zone`, `api`))) ORDER BY time"
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
      "title": "Zonal GCP API Latency in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 37,
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
          "rawSql": "SELECT time, concat(`api`, '/', `zone`) AS metric, value FROM (SELECT time, `zone`, if(match(`api`, '^(?:compute.(.*))$'), replaceRegexpOne(`api`, '^(?:compute.(.*))$', '\\\\1'), `api`) AS `api`, value FROM (SELECT time, `api`, `zone`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `api`, `zone`, sum(value) AS value FROM (SELECT time, `api`, `zone`, sum(value) AS value FROM (SELECT time, `api`, `zone`, d / dt AS value FROM (SELECT time, `api`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `api`, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`, `zone`) GROUP BY time, `api`, `zone`) AS a ALL INNER JOIN (SELECT time, `api`, `zone`, sum(value) AS value FROM (SELECT time, `api`, `zone`, sum(value) AS value FROM (SELECT time, `api`, `zone`, d / dt AS value FROM (SELECT time, `api`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['api'] AS `api`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.api.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `api`, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `api`, `zone`) GROUP BY time, `api`, `zone`) AS b USING (time, `api`, `zone`))) ORDER BY time"
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
      "title": "Batch Calls",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 45,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 19,
      "type": "timeseries",
      "title": "GCP Batch Size (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 46,
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
          "rawSql": "SELECT time, `context` AS metric, value FROM (SELECT time, if(match(`context`, '^(?:(.*)Caching(.*))$'), replaceRegexpOne(`context`, '^(?:(.*)Caching(.*))$', '\\\\1\\\\2'), `context`) AS `context`, value FROM (SELECT time, `context`, sum(value) AS value FROM (SELECT time, `context`, d / dt AS value FROM (SELECT time, `context`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['context'] AS `context`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'clouddriver.google.batchSize' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) GROUP BY time, series, `context`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `context`)) ORDER BY time"
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
      "id": 20,
      "type": "timeseries",
      "title": "GCP Batch Count (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 46,
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
          "rawSql": "SELECT time, `context` AS metric, value FROM (SELECT time, if(match(`context`, '^(?:(.*)Caching(.*))$'), replaceRegexpOne(`context`, '^(?:(.*)Caching(.*))$', '\\\\1\\\\2'), `context`) AS `context`, value FROM (SELECT time, `context`, sum(value) AS value FROM (SELECT time, `context`, d / dt AS value FROM (SELECT time, `context`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['context'] AS `context`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.batchExecute.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) GROUP BY time, series, `context`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `context`)) ORDER BY time"
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
      "title": "GCP Batch Latency (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 46,
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
          "rawSql": "SELECT time, `context` AS metric, value FROM (SELECT time, if(match(`context`, '^(?:(.*)Caching(.*))$'), replaceRegexpOne(`context`, '^(?:(.*)Caching(.*))$', '\\\\1\\\\2'), `context`) AS `context`, value FROM (SELECT time, `context`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `context`, sum(value) AS value FROM (SELECT time, `context`, d / dt AS value FROM (SELECT time, `context`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['context'] AS `context`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.batchExecute.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) GROUP BY time, series, `context`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `context`) AS a ALL INNER JOIN (SELECT time, `context`, sum(value) AS value FROM (SELECT time, `context`, d / dt AS value FROM (SELECT time, `context`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['context'] AS `context`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.batchExecute.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) GROUP BY time, series, `context`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `context`) AS b USING (time, `context`))) ORDER BY time"
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
      "id": 22,
      "type": "row",
      "title": "GCP Operations Outcome",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 54,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 23,
      "type": "timeseries",
      "title": "Successful GCP Operations (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 55,
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
          "rawSql": "SELECT time, `basePhase` AS metric, value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['status'] = 'DONE' GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) ORDER BY time"
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
      "title": "Failed GCP Operations (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 55,
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
          "rawSql": "SELECT time, concat(`scope`, '/', `basePhase`) AS metric, value FROM (SELECT time, `basePhase`, `scope`, sum(value) AS value FROM (SELECT time, `basePhase`, `scope`, d / dt AS value FROM (SELECT time, `basePhase`, `scope`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['scope'] AS `scope`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['status'] != 'DONE' GROUP BY time, series, `basePhase`, `scope`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`, `scope`) ORDER BY time"
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
      "type": "row",
      "title": "Waiting GCP Operations",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 63,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 26,
      "type": "timeseries",
      "title": "Global GCP Operation Waiting (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 64,
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
          "rawSql": "SELECT time, `basePhase` AS metric, value FROM (SELECT time, `basePhase`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) GROUP BY time, `basePhase`) AS a ALL INNER JOIN (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) GROUP BY time, `basePhase`) AS b USING (time, `basePhase`)) ORDER BY time"
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
      "title": "Regional GCP Operation Waiting in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 64,
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
          "rawSql": "SELECT time, concat(`basePhase`, '//', `region`) AS metric, value FROM (SELECT time, `region`, `basePhase`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `region`, `basePhase`, sum(value) AS value FROM (SELECT time, `region`, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, `region`, d / dt AS value FROM (SELECT time, `basePhase`, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['region'] AS `region`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `basePhase`, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`, `basePhase`) GROUP BY time, `region`, `basePhase`) AS a ALL INNER JOIN (SELECT time, `region`, `basePhase`, sum(value) AS value FROM (SELECT time, `region`, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, `region`, d / dt AS value FROM (SELECT time, `basePhase`, `region`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['region'] AS `region`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `basePhase`, `region`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `region`, `basePhase`) GROUP BY time, `region`, `basePhase`) AS b USING (time, `region`, `basePhase`)) ORDER BY time"
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
      "title": "Zonal GCP Operation Waiting in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 64,
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
          "rawSql": "SELECT time, concat(`basePhase`, '/', `cell`) AS metric, value FROM (SELECT time, `basePhase`, `cell`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `basePhase`, `cell`, sum(value) AS value FROM (SELECT time, `basePhase`, `cell`, sum(value) AS value FROM (SELECT time, `basePhase`, `zone`, if(match(`zone`, '^(?:.*-(.))$'), replaceRegexpOne(`zone`, '^(?:.*-(.))$', '\\\\1'), '') AS `cell`, value FROM (SELECT time, `basePhase`, `zone`, d / dt AS value FROM (SELECT time, `basePhase`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `basePhase`, `zone`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `basePhase`, `cell`) GROUP BY time, `basePhase`, `cell`) AS a ALL INNER JOIN (SELECT time, `basePhase`, `cell`, sum(value) AS value FROM (SELECT time, `basePhase`, `cell`, sum(value) AS value FROM (SELECT time, `basePhase`, `zone`, if(match(`zone`, '^(?:.*-(.))$'), replaceRegexpOne(`zone`, '^(?:.*-(.))$', '\\\\1'), '') AS `cell`, value FROM (SELECT time, `basePhase`, `zone`, d / dt AS value FROM (SELECT time, `basePhase`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.operationWaits.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `basePhase`, `zone`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `basePhase`, `cell`) GROUP BY time, `basePhase`, `cell`) AS b USING (time, `basePhase`, `cell`)) ORDER BY time"
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
      "type": "row",
      "title": "Started GCP Operations",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 72,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 30,
      "type": "timeseries",
      "title": "Global GCP Operations Started (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 73,
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
          "rawSql": "SELECT time, `basePhase` AS metric, value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'clouddriver.google.operationWaitRequests' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) ORDER BY time"
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
      "id": 31,
      "type": "timeseries",
      "title": "Regional GCP Operations Started in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 73,
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
          "rawSql": "SELECT time, `basePhase` AS metric, value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'clouddriver.google.operationWaitRequests' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) ORDER BY time"
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
      "title": "Zonal GCP Operations Started in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 73,
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
          "rawSql": "SELECT time, `basePhase` AS metric, value FROM (SELECT time, `basePhase`, sum(value) AS value FROM (SELECT time, `basePhase`, d / dt AS value FROM (SELECT time, `basePhase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['basePhase'] AS `basePhase`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'clouddriver.google.operationWaitRequests' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `basePhase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `basePhase`) ORDER BY time"
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
      "type": "row",
      "title": "Safe Retry Count",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 81,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 34,
      "type": "timeseries",
      "title": "Retryable Global GCP (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 82,
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
          "rawSql": "SELECT time, concat(`phase`, '.', `operation`) AS metric, value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `phase`, if(match(`operation`, '^(?:compute.(.*))$'), replaceRegexpOne(`operation`, '^(?:compute.(.*))$', '\\\\1'), `operation`) AS `operation`, value FROM (SELECT time, `operation`, `phase`, d / dt AS value FROM (SELECT time, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0)) GROUP BY time, `operation`, `phase`) ORDER BY time"
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
      "type": "row",
      "title": "Safe Retry Latency",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 90,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 36,
      "type": "timeseries",
      "title": "Retryable Regional GCP in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 91,
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
          "rawSql": "SELECT time, concat(`phase`, '.', `operation`) AS metric, value FROM (SELECT time, `instance`, `phase`, if(match(`operation`, '^(?:compute.(.*))$'), replaceRegexpOne(`operation`, '^(?:compute.(.*))$', '\\\\1'), `operation`) AS `operation`, value FROM (SELECT time, `instance`, `phase`, `operation`, sum(value) AS value FROM (SELECT time, `instance`, `operation`, `phase`, d / dt AS value FROM (SELECT time, `instance`, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ResourceAttributes['service.instance.id'] AS `instance`, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `instance`, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`, `phase`, `operation`)) ORDER BY time"
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
      "id": 37,
      "type": "timeseries",
      "title": "Retryable Zonal GCP in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 91,
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
          "rawSql": "SELECT time, concat(`phase`, '.', `operation`, '/', `cell`) AS metric, value FROM (SELECT time, `instance`, `phase`, `operation`, if(match('', '^(?:.*-(.))$'), replaceRegexpOne('', '^(?:.*-(.))$', '\\\\1'), `cell`) AS `cell`, value FROM (SELECT time, `instance`, `phase`, `cell`, if(match(`operation`, '^(?:compute.(.*))$'), replaceRegexpOne(`operation`, '^(?:compute.(.*))$', '\\\\1'), `operation`) AS `operation`, value FROM (SELECT time, `instance`, `phase`, `operation`, `cell`, sum(value) AS value FROM (SELECT time, `cell`, `instance`, `operation`, `phase`, d / dt AS value FROM (SELECT time, `cell`, `instance`, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cell'] AS `cell`, ResourceAttributes['service.instance.id'] AS `instance`, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `cell`, `instance`, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `instance`, `phase`, `operation`, `cell`))) ORDER BY time"
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
      "title": "Retryable Global GCP Latency (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 91,
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
          "rawSql": "SELECT time, concat(`phase`, '.', `operation`) AS metric, value FROM (SELECT time, `phase`, if(match(`operation`, '^(?:compute.(.*))$'), replaceRegexpOne(`operation`, '^(?:compute.(.*))$', '\\\\1'), `operation`) AS `operation`, value FROM (SELECT time, `operation`, `phase`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, d / dt AS value FROM (SELECT time, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `operation`, `phase`) GROUP BY time, `operation`, `phase`) AS a ALL INNER JOIN (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, d / dt AS value FROM (SELECT time, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'global' GROUP BY time, series, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `operation`, `phase`) GROUP BY time, `operation`, `phase`) AS b USING (time, `operation`, `phase`))) ORDER BY time"
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
      "id": 39,
      "type": "timeseries",
      "title": "Retryable Regional GCP Latency in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 91,
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
          "rawSql": "SELECT time, concat(`phase`, '.', `operation`) AS metric, value FROM (SELECT time, `phase`, if(match(`operation`, '^(?:compute.(.*))$'), replaceRegexpOne(`operation`, '^(?:compute.(.*))$', '\\\\1'), `operation`) AS `operation`, value FROM (SELECT time, `operation`, `phase`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, d / dt AS value FROM (SELECT time, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `operation`, `phase`) GROUP BY time, `operation`, `phase`) AS a ALL INNER JOIN (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, d / dt AS value FROM (SELECT time, `operation`, `phase`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'regional' AND Attributes['region'] IN ($GcpRegion) GROUP BY time, series, `operation`, `phase`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `operation`, `phase`) GROUP BY time, `operation`, `phase`) AS b USING (time, `operation`, `phase`))) ORDER BY time"
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
      "id": 40,
      "type": "timeseries",
      "title": "Retryable Zonal GCP Latency in $GcpRegion (clouddriver, $ClouddriverInstance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 99,
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
          "rawSql": "SELECT time, concat(`phase`, '.', `operation`, '/', `cell`) AS metric, value FROM (SELECT time, `phase`, `cell`, if(match(`operation`, '^(?:compute.(.*))$'), replaceRegexpOne(`operation`, '^(?:compute.(.*))$', '\\\\1'), `operation`) AS `operation`, value FROM (SELECT time, `phase`, `operation`, `cell`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, `zone`, if(match(`zone`, '^(?:.*-(.))$'), replaceRegexpOne(`zone`, '^(?:.*-(.))$', '\\\\1'), '') AS `cell`, value FROM (SELECT time, `operation`, `phase`, `zone`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `operation`, `phase`, `zone`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, `zone`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, `zone`, d / dt AS value FROM (SELECT time, `operation`, `phase`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `operation`, `phase`, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `operation`, `phase`, `zone`) GROUP BY time, `operation`, `phase`, `zone`) AS a ALL INNER JOIN (SELECT time, `operation`, `phase`, `zone`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, `zone`, sum(value) AS value FROM (SELECT time, `operation`, `phase`, `zone`, d / dt AS value FROM (SELECT time, `operation`, `phase`, `zone`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['operation'] AS `operation`, Attributes['phase'] AS `phase`, Attributes['zone'] AS `zone`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'clouddriver.google.safeRetry.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($ClouddriverInstance) AND Attributes['scope'] = 'zonal' AND arrayExists(x -> match(Attributes['zone'], concat('^(?:.*', x, '.*)$')), [$GcpRegion]) GROUP BY time, series, `operation`, `phase`, `zone`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `operation`, `phase`, `zone`) GROUP BY time, `operation`, `phase`, `zone`) AS b USING (time, `operation`, `phase`, `zone`))) GROUP BY time, `phase`, `operation`, `cell`)) ORDER BY time"
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
      "id": 41,
      "type": "row",
      "title": "Google Storage",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 107,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 42,
      "type": "timeseries",
      "title": "Google Storage Service Calls (front50, $Front50Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 108,
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
          "rawSql": "SELECT time, `method` AS metric, value FROM (SELECT time, `method`, sum(value) AS value FROM (SELECT time, `method`, d / dt AS value FROM (SELECT time, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['method'] AS `method`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'front50.google.storage.invocation.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Front50Instance) GROUP BY time, series, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `method`) ORDER BY time"
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
      "type": "timeseries",
      "title": "Google Storage Service Latency (front50, $Front50Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 108,
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
          "rawSql": "SELECT time, `method` AS metric, value FROM (SELECT time, `method`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `method`, sum(value) AS value FROM (SELECT time, `method`, sum(value) AS value FROM (SELECT time, `method`, d / dt AS value FROM (SELECT time, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['method'] AS `method`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'front50.google.storage.invocation.totalTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Front50Instance) GROUP BY time, series, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `method`) GROUP BY time, `method`) AS a ALL INNER JOIN (SELECT time, `method`, sum(value) AS value FROM (SELECT time, `method`, sum(value) AS value FROM (SELECT time, `method`, d / dt AS value FROM (SELECT time, `method`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['method'] AS `method`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'front50.google.storage.invocation.count' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Front50Instance) GROUP BY time, series, `method`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `method`) GROUP BY time, `method`) AS b USING (time, `method`)) ORDER BY time"
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
