{
  "title": "Spinnaker AWS Platform (ClickHouse)",
  "uid": "ch-spinnaker-aws-platform",
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
        "name": "AwsRegion",
        "label": "AwsRegion",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT Attributes['region'] FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT Attributes['region'] FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "definition": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
      "title": "AWS",
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
      "title": "AWS Delay by Service  (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`serviceName`, ' / UNK') AS metric, value FROM (SELECT time, if(match(`serviceName`, '^(?:Amazon(.+))$'), replaceRegexpOne(`serviceName`, '^(?:Amazon(.+))$', '\\\\1'), `serviceName`) AS `serviceName`, value FROM (SELECT time, `serviceName`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceName`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceName'] AS `serviceName`, argMax(Sum, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] = '-1' GROUP BY time, series, `serviceName`) GROUP BY time, `serviceName`) GROUP BY time, `serviceName`) AS a ALL INNER JOIN (SELECT time, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceName`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceName'] AS `serviceName`, argMax(Count, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] = '-1' GROUP BY time, series, `serviceName`) GROUP BY time, `serviceName`) GROUP BY time, `serviceName`) AS b USING (time, `serviceName`))) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`serviceName`, ' / ', `statusCode`) AS metric, value FROM (SELECT time, `statusCode`, if(match(`serviceName`, '^(?:Amazon(.+))$'), replaceRegexpOne(`serviceName`, '^(?:Amazon(.+))$', '\\\\1'), `serviceName`) AS `serviceName`, value FROM (SELECT time, `serviceName`, `statusCode`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `serviceName`, `statusCode`, sum(value) AS value FROM (SELECT time, `serviceName`, `statusCode`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceName'] AS `serviceName`, Attributes['statusCode'] AS `statusCode`, argMax(Sum, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] != '-1' GROUP BY time, series, `serviceName`, `statusCode`) GROUP BY time, `serviceName`, `statusCode`) GROUP BY time, `serviceName`, `statusCode`) AS a ALL INNER JOIN (SELECT time, `serviceName`, `statusCode`, sum(value) AS value FROM (SELECT time, `serviceName`, `statusCode`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceName'] AS `serviceName`, Attributes['statusCode'] AS `statusCode`, argMax(Count, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] != '-1' GROUP BY time, series, `serviceName`, `statusCode`) GROUP BY time, `serviceName`, `statusCode`) GROUP BY time, `serviceName`, `statusCode`) AS b USING (time, `serviceName`, `statusCode`))) ORDER BY time"
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
      "id": 3,
      "type": "timeseries",
      "title": "AWS Delay by Request (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`requestType`, ' / UNK') AS metric, value FROM (SELECT time, `requestType`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `requestType`, sum(value) AS value FROM (SELECT time, `requestType`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, argMax(Sum, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] = '-1' GROUP BY time, series, `requestType`) GROUP BY time, `requestType`) GROUP BY time, `requestType`) AS a ALL INNER JOIN (SELECT time, `requestType`, sum(value) AS value FROM (SELECT time, `requestType`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, argMax(Count, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] = '-1' GROUP BY time, series, `requestType`) GROUP BY time, `requestType`) GROUP BY time, `requestType`) AS b USING (time, `requestType`)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, concat(`requestType`, ' / ', `statusCode`) AS metric, value FROM (SELECT time, `requestType`, `statusCode`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `requestType`, `statusCode`, sum(value) AS value FROM (SELECT time, `requestType`, `statusCode`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['statusCode'] AS `statusCode`, argMax(Sum, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] != '-1' GROUP BY time, series, `requestType`, `statusCode`) GROUP BY time, `requestType`, `statusCode`) GROUP BY time, `requestType`, `statusCode`) AS a ALL INNER JOIN (SELECT time, `requestType`, `statusCode`, sum(value) AS value FROM (SELECT time, `requestType`, `statusCode`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['statusCode'] AS `statusCode`, argMax(Count, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'AWS.delay' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['statusCode'] != '-1' GROUP BY time, series, `requestType`, `statusCode`) GROUP BY time, `requestType`, `statusCode`) GROUP BY time, `requestType`, `statusCode`) AS b USING (time, `requestType`, `statusCode`)) ORDER BY time"
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
      "id": 4,
      "type": "timeseries",
      "title": "AWS Errors by Region (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`region`, ' / ', `statusCode`) AS metric, value FROM (SELECT time, `serviceEndpoint`, `statusCode`, if(match(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$'), replaceRegexpOne(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$', '\\\\1'), '') AS `region`, value FROM (SELECT time, `serviceEndpoint`, `statusCode`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `statusCode`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['error'] = 'true' GROUP BY time, series, `serviceEndpoint`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceEndpoint`, `statusCode`)) ORDER BY time"
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
      "title": "AWS Errors in $AwsRegion (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`statusCode`, '/', `serviceName`, '.', `requestType`, '->', `AWSErrorCode`) AS metric, value FROM (SELECT time, `statusCode`, `AWSErrorCode`, `requestType`, if(match(`serviceName`, '^(?:Amazon(.+))$'), replaceRegexpOne(`serviceName`, '^(?:Amazon(.+))$', '\\\\1'), `serviceName`) AS `serviceName`, value FROM (SELECT time, `serviceName`, `statusCode`, `AWSErrorCode`, if(match(`requestType`, '^(?:(.*)Request(.*))$'), replaceRegexpOne(`requestType`, '^(?:(.*)Request(.*))$', '\\\\1'), `requestType`) AS `requestType`, value FROM (SELECT time, `requestType`, `serviceName`, `statusCode`, `AWSErrorCode`, sum(value) AS value FROM (SELECT time, `AWSErrorCode`, `requestType`, `serviceName`, `statusCode`, d / dt AS value FROM (SELECT time, `AWSErrorCode`, `requestType`, `serviceName`, `statusCode`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['AWSErrorCode'] AS `AWSErrorCode`, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, Attributes['statusCode'] AS `statusCode`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['error'] = 'true' GROUP BY time, series, `AWSErrorCode`, `requestType`, `serviceName`, `statusCode`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`, `statusCode`, `AWSErrorCode`))) ORDER BY time"
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
      "title": "AWS EC2 Requests  by Region (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, `region` AS metric, value FROM (SELECT time, `serviceEndpoint`, if(match(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$'), replaceRegexpOne(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$', '\\\\1'), '') AS `region`, value FROM (SELECT time, `serviceEndpoint`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['serviceName'] = 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `serviceEndpoint`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceEndpoint`)) ORDER BY time"
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
      "title": "AWS EC2 Requests in $AwsRegion (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, `requestType` AS metric, value FROM (SELECT time, `serviceName`, if(match(`requestType`, '^(?:(.*)Request)$'), replaceRegexpOne(`requestType`, '^(?:(.*)Request)$', '\\\\1'), `requestType`) AS `requestType`, value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, d / dt AS value FROM (SELECT time, `requestType`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] = 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `requestType`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`)) ORDER BY time"
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
      "title": "AWS EC2 Request Latency by Region  (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, `region` AS metric, value FROM (SELECT time, `serviceEndpoint`, `serviceName`, if(match(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$'), replaceRegexpOne(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$', '\\\\1'), '') AS `region`, value FROM (SELECT time, `serviceEndpoint`, `serviceName`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, Attributes['serviceName'] AS `serviceName`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] = 'AmazonEC2' GROUP BY time, series, `serviceEndpoint`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceEndpoint`, `serviceName`) GROUP BY time, `serviceEndpoint`, `serviceName`) AS a ALL INNER JOIN (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['serviceName'] = 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `serviceEndpoint`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceEndpoint`, `serviceName`) GROUP BY time, `serviceEndpoint`, `serviceName`) AS b USING (time, `serviceEndpoint`, `serviceName`))) ORDER BY time"
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
      "type": "timeseries",
      "title": "AWS EC2 Request Latency in $AwsRegion  (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, `requestType` AS metric, value FROM (SELECT time, `requestType`, `serviceName`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, d / dt AS value FROM (SELECT time, `requestType`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] = 'AmazonEC2' GROUP BY time, series, `requestType`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`) GROUP BY time, `requestType`, `serviceName`) AS a ALL INNER JOIN (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, d / dt AS value FROM (SELECT time, `requestType`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['serviceName'] = 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `requestType`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`) GROUP BY time, `requestType`, `serviceName`) AS b USING (time, `requestType`, `serviceName`)) ORDER BY time"
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
      "title": "AWS Requests (non EC2) by Region (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 17,
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
          "rawSql": "SELECT time, concat(`serviceName`, ' / ', `region`) AS metric, value FROM (SELECT time, `serviceName`, `serviceEndpoint`, if(match(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$'), replaceRegexpOne(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$', '\\\\1'), '') AS `region`, value FROM (SELECT time, `serviceName`, `serviceEndpoint`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] != 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `serviceEndpoint`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceName`, `serviceEndpoint`)) ORDER BY time"
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
      "title": "AWS Requests (non EC2) in $AwsRegion (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 17,
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
          "rawSql": "SELECT time, concat(`serviceName`, '.', `requestType`) AS metric, value FROM (SELECT time, `requestType`, if(match(`serviceName`, '^(?:Amazon(.+))$'), replaceRegexpOne(`serviceName`, '^(?:Amazon(.+))$', '\\\\1'), `serviceName`) AS `serviceName`, value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, d / dt AS value FROM (SELECT time, `requestType`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] != 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `requestType`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`)) ORDER BY time"
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
      "title": "AWS Non-EC2 Request Latency by Region  (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 17,
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
          "rawSql": "SELECT time, concat(`serviceName`, ' / ', `region`) AS metric, value FROM (SELECT time, `serviceEndpoint`, `serviceName`, if(match(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$'), replaceRegexpOne(`serviceEndpoint`, '^(?:[^\\\\.]+\\\\.([^\\\\.]+).*)$', '\\\\1'), '') AS `region`, value FROM (SELECT time, `serviceEndpoint`, if(match(`serviceName`, '^(?:Amazon(.+))$'), replaceRegexpOne(`serviceName`, '^(?:Amazon(.+))$', '\\\\1'), `serviceName`) AS `serviceName`, value FROM (SELECT time, `serviceEndpoint`, `serviceName`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, Attributes['serviceName'] AS `serviceName`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] != 'AmazonEC2' GROUP BY time, series, `serviceEndpoint`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceEndpoint`, `serviceName`) GROUP BY time, `serviceEndpoint`, `serviceName`) AS a ALL INNER JOIN (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, sum(value) AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, d / dt AS value FROM (SELECT time, `serviceEndpoint`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['serviceEndpoint'] AS `serviceEndpoint`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND Attributes['serviceName'] != 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `serviceEndpoint`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `serviceEndpoint`, `serviceName`) GROUP BY time, `serviceEndpoint`, `serviceName`) AS b USING (time, `serviceEndpoint`, `serviceName`)))) ORDER BY time"
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
      "id": 13,
      "type": "timeseries",
      "title": "AWS Non-EC2 Request Latency in $AwsRegion  (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 17,
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
          "rawSql": "SELECT time, concat(`serviceName`, '.', `requestType`) AS metric, value FROM (SELECT time, `serviceName`, if(match(`requestType`, '^(?:(.*)Request)$'), replaceRegexpOne(`requestType`, '^(?:(.*)Request)$', '\\\\1'), `requestType`) AS `requestType`, value FROM (SELECT time, `requestType`, if(match(`serviceName`, '^(?:Amazon(.+))$'), replaceRegexpOne(`serviceName`, '^(?:Amazon(.+))$', '\\\\1'), `serviceName`) AS `serviceName`, value FROM (SELECT time, `requestType`, `serviceName`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, d / dt AS value FROM (SELECT time, `requestType`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND arrayExists(x -> match(Attributes['serviceEndpoint'], concat('^(?:.*', x, '.*)$')), [$AwsRegion]) AND Attributes['serviceName'] != 'AmazonEC2' GROUP BY time, series, `requestType`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`) GROUP BY time, `requestType`, `serviceName`) AS a ALL INNER JOIN (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, sum(value) AS value FROM (SELECT time, `requestType`, `serviceName`, d / dt AS value FROM (SELECT time, `requestType`, `serviceName`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['requestType'] AS `requestType`, Attributes['serviceName'] AS `serviceName`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'aws.request.httpRequestTime' AND $__timeFilter(TimeUnix) AND Attributes['serviceName'] != 'AmazonEC2' AND Attributes['error'] = 'false' GROUP BY time, series, `requestType`, `serviceName`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `requestType`, `serviceName`) GROUP BY time, `requestType`, `serviceName`) AS b USING (time, `requestType`, `serviceName`)))) ORDER BY time"
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
