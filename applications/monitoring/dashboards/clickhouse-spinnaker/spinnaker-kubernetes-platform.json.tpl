{
  "title": "Spinnaker Kubernetes Platform (ClickHouse)",
  "uid": "ch-spinnaker-kubernetes-platform",
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
        "name": "KubernetesAccount",
        "label": "KubernetesAccount",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT Attributes['account'] FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT Attributes['account'] FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "name": "KubernetesNamespace",
        "label": "KubernetesNamespace",
        "type": "query",
        "datasource": {
          "type": "grafana-clickhouse-datasource",
          "uid": "${ch_uid}"
        },
        "definition": "SELECT DISTINCT Attributes['namespace'] FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT Attributes['namespace'] FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
      "title": "Kubernetes",
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
      "title": "Kubernetes Success for \"$KubernetesAccount\" in \"$KubernetesNamespace\" (clouddriver)",
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
          "rawSql": "SELECT time, `action` AS metric, value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, d / dt AS value FROM (SELECT time, `action`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['namespace'] IN ($KubernetesNamespace) AND Attributes['account'] IN ($KubernetesAccount) AND Attributes['success'] = 'true' GROUP BY time, series, `action`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`) ORDER BY time"
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
      "title": "Kubernetes Latency for \"$KubernetesAccount\" in \"$KubernetesNamespace\" (clouddriver)",
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
          "rawSql": "SELECT time, `action` AS metric, value FROM (SELECT time, `action`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, d / dt AS value FROM (SELECT time, `action`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['namespace'] IN ($KubernetesNamespace) AND Attributes['success'] = 'true' AND Attributes['account'] IN ($KubernetesAccount) GROUP BY time, series, `action`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`) GROUP BY time, `action`) AS a ALL INNER JOIN (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, d / dt AS value FROM (SELECT time, `action`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['namespace'] IN ($KubernetesNamespace) AND Attributes['account'] IN ($KubernetesAccount) AND Attributes['success'] = 'true' GROUP BY time, series, `action`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`) GROUP BY time, `action`) AS b USING (time, `action`)) ORDER BY time"
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
      "title": "Kubernetes Failure for \"$KubernetesAccount\" in \"$KubernetesNamespace\" (clouddriver)",
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
          "rawSql": "SELECT time, concat(`action`, '/', `reason`) AS metric, value FROM (SELECT time, `action`, `reason`, sum(value) AS value FROM (SELECT time, `action`, `reason`, d / dt AS value FROM (SELECT time, `action`, `reason`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, Attributes['reason'] AS `reason`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['namespace'] IN ($KubernetesNamespace) AND Attributes['account'] IN ($KubernetesAccount) AND Attributes['success'] != 'true' GROUP BY time, series, `action`, `reason`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`, `reason`) ORDER BY time"
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
      "title": "Kubernetes Failure Latency for \"$KubernetesAccount\" in \"$KubernetesNamespace\" (clouddriver)",
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
          "rawSql": "SELECT time, `action` AS metric, value FROM (SELECT time, `action`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, `reason`, sum(value) AS value FROM (SELECT time, `action`, `reason`, d / dt AS value FROM (SELECT time, `action`, `reason`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, Attributes['reason'] AS `reason`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['namespace'] IN ($KubernetesNamespace) AND Attributes['success'] != 'true' AND Attributes['account'] IN ($KubernetesAccount) GROUP BY time, series, `action`, `reason`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`, `reason`) GROUP BY time, `action`) AS a ALL INNER JOIN (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, sum(value) AS value FROM (SELECT time, `action`, d / dt AS value FROM (SELECT time, `action`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['action'] AS `action`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['namespace'] IN ($KubernetesNamespace) AND Attributes['account'] IN ($KubernetesAccount) AND Attributes['success'] != 'true' GROUP BY time, series, `action`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `action`) GROUP BY time, `action`) AS b USING (time, `action`)) ORDER BY time"
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
      "id": 6,
      "type": "timeseries",
      "title": "Kubernetes Success by Kind (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, `kinds` AS metric, value FROM (SELECT time, `kinds`, sum(value) AS value FROM (SELECT time, `kinds`, d / dt AS value FROM (SELECT time, `kinds`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['kinds'] AS `kinds`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `kinds`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `kinds`) ORDER BY time"
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
      "title": "Kubernetes Success by Account (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`account`, ' ') AS metric, value FROM (SELECT time, `account`, sum(value) AS value FROM (SELECT time, `account`, d / dt AS value FROM (SELECT time, `account`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['account'] AS `account`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `account`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `account`) ORDER BY time"
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
      "title": "Kubernetes Success by Namespace (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat('', ' ') AS metric, value FROM (SELECT time, `namespace`, sum(value) AS value FROM (SELECT time, `namespace`, d / dt AS value FROM (SELECT time, `namespace`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['namespace'] AS `namespace`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `namespace`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `namespace`) ORDER BY time"
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
      "title": "Kubernetes Latency by Kind (clouddriver)",
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
          "rawSql": "SELECT time, `kinds` AS metric, value FROM (SELECT time, `kinds`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `kinds`, sum(value) AS value FROM (SELECT time, `kinds`, sum(value) AS value FROM (SELECT time, `kinds`, d / dt AS value FROM (SELECT time, `kinds`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['kinds'] AS `kinds`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `kinds`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `kinds`) GROUP BY time, `kinds`) AS a ALL INNER JOIN (SELECT time, `kinds`, sum(value) AS value FROM (SELECT time, `kinds`, sum(value) AS value FROM (SELECT time, `kinds`, d / dt AS value FROM (SELECT time, `kinds`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['kinds'] AS `kinds`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `kinds`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `kinds`) GROUP BY time, `kinds`) AS b USING (time, `kinds`)) ORDER BY time"
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
      "title": "Kubernetes Latency by Account (clouddriver)",
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
          "rawSql": "SELECT time, `account` AS metric, value FROM (SELECT time, `account`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `account`, sum(value) AS value FROM (SELECT time, `account`, sum(value) AS value FROM (SELECT time, `account`, d / dt AS value FROM (SELECT time, `account`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['account'] AS `account`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `account`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `account`) GROUP BY time, `account`) AS a ALL INNER JOIN (SELECT time, `account`, sum(value) AS value FROM (SELECT time, `account`, sum(value) AS value FROM (SELECT time, `account`, d / dt AS value FROM (SELECT time, `account`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['account'] AS `account`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `account`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `account`) GROUP BY time, `account`) AS b USING (time, `account`)) ORDER BY time"
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
      "id": 11,
      "type": "timeseries",
      "title": "Kubernetes Latency by Namespace (clouddriver)",
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
          "rawSql": "SELECT time, '' AS metric, value FROM (SELECT time, `namespace`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `namespace`, sum(value) AS value FROM (SELECT time, `namespace`, sum(value) AS value FROM (SELECT time, `namespace`, d / dt AS value FROM (SELECT time, `namespace`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['namespace'] AS `namespace`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `namespace`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `namespace`) GROUP BY time, `namespace`) AS a ALL INNER JOIN (SELECT time, `namespace`, sum(value) AS value FROM (SELECT time, `namespace`, sum(value) AS value FROM (SELECT time, `namespace`, d / dt AS value FROM (SELECT time, `namespace`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['namespace'] AS `namespace`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] = 'true' GROUP BY time, series, `namespace`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `namespace`) GROUP BY time, `namespace`) AS b USING (time, `namespace`)) ORDER BY time"
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
      "title": "Kubernetes Failure by Kind (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`kinds`, ' ') AS metric, value FROM (SELECT time, `kinds`, sum(value) AS value FROM (SELECT time, `kinds`, d / dt AS value FROM (SELECT time, `kinds`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['kinds'] AS `kinds`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] != 'true' GROUP BY time, series, `kinds`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `kinds`) ORDER BY time"
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
      "title": "Kubernetes Failure by Account (clouddriver, $Instance)",
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
          "rawSql": "SELECT time, concat(`account`, ' ') AS metric, value FROM (SELECT time, `account`, sum(value) AS value FROM (SELECT time, `account`, d / dt AS value FROM (SELECT time, `account`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['account'] AS `account`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] != 'true' GROUP BY time, series, `account`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `account`) ORDER BY time"
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
      "title": "Kubernetes Failure by Namespace (clouddriver, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 25,
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
          "rawSql": "SELECT time, concat('', ' ') AS metric, value FROM (SELECT time, `namespace`, sum(value) AS value FROM (SELECT time, `namespace`, d / dt AS value FROM (SELECT time, `namespace`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['namespace'] AS `namespace`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'kubernetes.api' AND $__timeFilter(TimeUnix) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['success'] != 'true' GROUP BY time, series, `namespace`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `namespace`) ORDER BY time"
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
    }
  ]
}
