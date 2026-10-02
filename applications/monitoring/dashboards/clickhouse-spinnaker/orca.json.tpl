{
  "title": "Orca (ClickHouse)",
  "uid": "ch-spinnaker-orca",
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
      "url": "https://github.com/spinnaker/orca"
    }
  ],
  "templating": {
    "list": [
      {
        "name": "spinSvc",
        "label": "",
        "type": "custom",
        "query": "orca",
        "current": {
          "text": "orca",
          "value": "orca"
        },
        "options": [
          {
            "text": "orca",
            "value": "orca"
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
        "definition": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE match(ServiceName, '^(?:.*orca.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ServiceName FROM otel.otel_metrics_gauge WHERE match(ServiceName, '^(?:.*orca.*)$') AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "definition": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_gauge WHERE ServiceName IN ($job) AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1",
        "query": {
          "rawSql": "SELECT DISTINCT ResourceAttributes['service.instance.id'] FROM otel.otel_metrics_gauge WHERE ServiceName IN ($job) AND TimeUnix > now() - INTERVAL 6 HOUR ORDER BY 1"
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
        "content": "Orca is the orchestration engine for Spinnaker. It is responsible for taking an execution definition and managing the stages and tasks, coordinating the other Spinnaker services."
      }
    },
    {
      "id": 3,
      "type": "timeseries",
      "title": "Active Executions",
      "description": "The primary domain model is an Execution, of which there are two types: PIPELINE and ORCHESTRATION. \n\nThe PIPELINE type is, you guessed it, for pipelines while ORCHESTRATION is what you see in the \u201cTasks\u201d tab for an application. \n\nThis is really just good insight for answering the question of workload distribution. \n\nSince adding this metric, we\u2019ve never seen it crater, but if that were to happen it\u2019d be bad. \n\nFor Netflix, most ORCHESTRATION executions are API clients. \n\nDisregarding what the execution is doing, there\u2019s no baseline cost difference between a running orchestration and a pipeline.",
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
          "rawSql": "SELECT time, `executionType` AS metric, value FROM (SELECT time, `executionType`, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['executionType'] AS `executionType`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'executions.active' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series, `executionType`) GROUP BY time, `executionType`) ORDER BY time"
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
      "title": "Controller Invocation Time",
      "description": "If you\u2019ve got a lot of 500\u2019s, check your logs. \n\nWhen we see a spike in either invocation times or 5xx errors, it\u2019s usually one of two things: \n\n1) Clouddriver is having a bad day, \n\n2) Orca doesn\u2019t have enough capacity in some respect to service people polling for pipeline status updates. \n\nYou\u2019ll need to dig elsewhere to find the cause.",
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
          "rawSql": "SELECT time, concat(`controller`, ' :: ', `status`) AS metric, value FROM (SELECT time, `controller`, `status`, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, `controller`, `status`, sum(value) AS value FROM (SELECT time, `controller`, `status`, sum(value) AS value FROM (SELECT time, `controller`, `status`, d / dt AS value FROM (SELECT time, `controller`, `status`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['status'] AS `status`, max(Sum) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series, `controller`, `status`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `status`) GROUP BY time, `controller`, `status`) AS a ALL INNER JOIN (SELECT time, `controller`, `status`, sum(value) AS value FROM (SELECT time, `controller`, `status`, sum(value) AS value FROM (SELECT time, `controller`, `status`, d / dt AS value FROM (SELECT time, `controller`, `status`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['controller'] AS `controller`, Attributes['status'] AS `status`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'controller.invocations' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series, `controller`, `status`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `controller`, `status`) GROUP BY time, `controller`, `status`) AS b USING (time, `controller`, `status`)) ORDER BY time"
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
      "id": 5,
      "type": "timeseries",
      "title": "Rate of Task Invocations",
      "description": "This will look similar to the first metric we looked at, but this is directly looking at our queue: \n\nThis is the number of Execution-related Messages that we\u2019re invoking every second.\n\nIf this drops, it\u2019s a sign that your QueueProcessor may be starting to freeze up.\n\nAt that point, check that the thread pool it\u2019s on isn\u2019t starved for threads.",
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
          "rawSql": "SELECT time, `executionType` AS metric, value FROM (SELECT time, `executionType`, sum(value) AS value FROM (SELECT time, `executionType`, d / dt AS value FROM (SELECT time, `executionType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['executionType'] AS `executionType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'task.invocations.duration' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series, `executionType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `executionType`) ORDER BY time"
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
      "title": "Task Invocations by Application",
      "description": "This is handy to see who your biggest customers are, from a pure orchestration volume perspective. \n\nOften times, if we start to experience pain and see a large uptick in queue usage, it\u2019ll be due to a large submission from one or two customers. \n\nIf we were having pain, we could bump our capacity, or look to adjust some rate limits.",
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
          "rawSql": "SELECT time, concat(`application`, ' - ', `executionType`) AS metric, value FROM (SELECT time, `application`, `executionType`, sum(value) AS value FROM (SELECT time, `application`, `executionType`, d / dt AS value FROM (SELECT time, `application`, `executionType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['application'] AS `application`, Attributes['executionType'] AS `executionType`, max(Count) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'task.invocations.duration' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') AND Attributes['status'] = 'RUNNING' GROUP BY time, series, `application`, `executionType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `application`, `executionType`) ORDER BY time"
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
      "title": "Message Handler Executor Usage",
      "description": "This is our thread pool for the Message Handlers.\n\n\nSpare capacity is good.\n\nActive is actual active usage.\n\nBlocking is when a thread is blocked. \n\nBlockingQueueSize is bad, especially \"pollSkippedNoCapacity\" should always block blockingQueueSize being changed from 0.",
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
          "rawSql": "SELECT time, 'Active' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'threadpool.activeCount' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'Blocking' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'threadpool.blockingQueueSize' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'Size' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'threadpool.poolSize' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series) GROUP BY time) ORDER BY time"
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
      "title": "Rate of Queue Messages Pushed / Acked (s)",
      "description": "If messages pushed is out pacing acked, you\u2019re presently having a bad time. \n\nMost messages will complete in a blink of an eye, only RunTask will really take much time. \n\nIf you see an uptick in messages pushed, but not a correlating ack\u2019d, it\u2019s a good indicator you\u2019ve got a downstream service issue that\u2019s preventing message handlers completing: \n\nTake a look at Clouddriver, it probably wants your love and attention.",
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
          "rawSql": "SELECT time, 'Pushed' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'queue.pushed.messages' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'Ack\\'d' AS metric, value FROM (SELECT time, sum(value) AS value FROM (SELECT time, d / dt AS value FROM (SELECT time, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'queue.acknowledged.messages' AND $__timeFilter(TimeUnix) AND match(ServiceName, '^(?:orca.*)$') GROUP BY time, series)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time) ORDER BY time"
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
      "title": "Queue Depth",
      "description": "Keiko supports setting a delivery time for messages, so you\u2019ll always see queued messages outpacing in-process messages if your Spinnaker install is active.\n\nThings like wait tasks, execution windows, retries, and so-on all schedule message delivery in the future, and in-process messages are usually in-process for a handful of milliseconds.\n\nOperating Orca, one of your life mission is to keep ready messages at 0. \n\nA ready message is a message that has a delivery time of now or in the past, but it hasn\u2019t been picked up and transitioned into processing yet: \n\nThis is a key contributor to a complaint of, \u201cSpinnaker is slow.\u201d \n\nAs I\u2019ve mentioned before, Orca is horizontally scalable. \n\nGive Orca an adrenaline shot of instances if you see ready messages over 0 for more than two intervals so you can clear the queue out.",
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
          "rawSql": "SELECT time, 'queued' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'queue.depth' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'ready' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'queue.ready.depth' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) GROUP BY time) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'unacked' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'queue.unacked.depth' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) GROUP BY time) ORDER BY time"
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
      "title": "Queue Errors (orca, $Instance)",
      "description": "Retried is a normal error condition by itself. \n\nDead-lettered occurs when a message has been retried a bunch of times and has never been successfully delivered.\n\nOrphaned messages are bad. \n\nThey\u2019re messages whose message contents are in the queue, but do not have a pointer in either the queue set or unacked set. \n\nThis is a sign of an internal error, likely a troubling issue with Redis. \n\nIt \u201cshould never happen\u201d if your system is healthy, and likewise \u201cshould never happen\u201d even if your system is really, really overloaded. It\u2019s worth a bug report.",
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
          "rawSql": "SELECT time, 'Retried' AS metric, value FROM (SELECT time, `job`, sum(value) AS value FROM (SELECT time, `job`, d / dt AS value FROM (SELECT time, `job`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ServiceName AS `job`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'queue.retried.messages' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `job`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `job`) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'Dead' AS metric, value FROM (SELECT time, `job`, sum(value) AS value FROM (SELECT time, `job`, d / dt AS value FROM (SELECT time, `job`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ServiceName AS `job`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'queue.dead.messages' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `job`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `job`) ORDER BY time"
        },
        {
          "refId": "C",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'Orphaned' AS metric, value FROM (SELECT time, `job`, sum(value) AS value FROM (SELECT time, `job`, d / dt AS value FROM (SELECT time, `job`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, ServiceName AS `job`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'queue.orphaned.messages' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `job`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `job`) ORDER BY time"
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
      "title": "Message Lag",
      "description": "This is a measurement of a message\u2019s desired delivery time and the actual delivery time: Smaller and tighter is better. This is a timer measurement of every message\u2019s (usually very short) life in a ready state. When your queue gets backed up, this number will grow. \n\nWe consider this one of Orca\u2019s key performance indicators.\n\nA mean message lag of anything under a few hundred milliseconds is fine. \n\nDon\u2019t panic until you\u2019re getting around a second. \n\nScale up, everything should be fine.",
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
          "rawSql": "SELECT time, 'mean' AS metric, value FROM (SELECT time, a.value / nullIf(b.value, 0) AS value FROM (SELECT time, sum(value) AS value FROM (SELECT time, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Sum, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'queue.message.lag' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) GROUP BY time) GROUP BY time) AS a ALL INNER JOIN (SELECT time, sum(value) AS value FROM (SELECT time, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Count, TimeUnix) AS value FROM otel.otel_metrics_histogram WHERE MetricName = 'queue.message.lag' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) GROUP BY time) GROUP BY time) AS b USING (time)) ORDER BY time"
        },
        {
          "refId": "B",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "queryType": "timeseries",
          "rawSql": "SELECT time, 'max' AS metric, value FROM (SELECT time, max(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'queue.message.lag.max' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series) GROUP BY time) ORDER BY time"
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
      "title": "Additional Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 25,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 13,
      "type": "timeseries",
      "title": "Active Stages per Type/Platform (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 26,
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
          "rawSql": "SELECT time, concat(`type`, '/', `cloudProvider`) AS metric, value FROM (SELECT time, `cloudProvider`, `type`, sum(value) AS value FROM (SELECT time, `cloudProvider`, `type`, d / dt AS value FROM (SELECT time, `cloudProvider`, `type`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cloudProvider'] AS `cloudProvider`, Attributes['type'] AS `type`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'stage.invocations' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `cloudProvider`, `type`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cloudProvider`, `type`) ORDER BY time"
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
      "title": "Stages Completed per Type/Platform (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 26,
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
          "rawSql": "SELECT time, concat(`stageType`, '/', `cloudProvider`) AS metric, value FROM (SELECT time, `cloudProvider`, `stageType`, sum(value) AS value FROM (SELECT time, `cloudProvider`, `stageType`, d / dt AS value FROM (SELECT time, `cloudProvider`, `stageType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['cloudProvider'] AS `cloudProvider`, Attributes['stageType'] AS `stageType`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'stage.invocations.duration' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `cloudProvider`, `stageType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `cloudProvider`, `stageType`) ORDER BY time"
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
      "id": 15,
      "type": "timeseries",
      "title": "Stage Durations > 5m per Time-Bucket/Platform (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 26,
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
          "rawSql": "SELECT time, concat(`bucket`, '/', `cloudProvider`, '/', `stageType`) AS metric, value FROM (SELECT time, `stageType`, `cloudProvider`, `bucket`, sum(value) AS value FROM (SELECT time, `bucket`, `cloudProvider`, `stageType`, d / dt AS value FROM (SELECT time, `bucket`, `cloudProvider`, `stageType`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['bucket'] AS `bucket`, Attributes['cloudProvider'] AS `cloudProvider`, Attributes['stageType'] AS `stageType`, max(Value) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'stage.invocations.duration' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) AND Attributes['bucket'] != 'lt5m' GROUP BY time, series, `bucket`, `cloudProvider`, `stageType`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `stageType`, `cloudProvider`, `bucket`) ORDER BY time"
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
      "title": "Blocked Queues (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
        "y": 26,
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
          "rawSql": "SELECT time, `id` AS metric, value FROM (SELECT time, `id`, sum(value) AS value FROM (SELECT time, `id`, d / dt AS value FROM (SELECT time, `id`, greatest(value - lagInFrame(toNullable(value), 1, NULL) OVER (PARTITION BY series ORDER BY time), 0) AS d, dateDiff('second', lagInFrame(toNullable(time), 1, NULL) OVER (PARTITION BY series ORDER BY time), time) AS dt FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['id'] AS `id`, max(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'threadpool.blockingQueueSize' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `id`)) WHERE d IS NOT NULL AND dt > 0) GROUP BY time, `id`) ORDER BY time"
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
      "title": "Zombie Queues (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 34,
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
          "rawSql": "SELECT time, `application` AS metric, value FROM (SELECT time, `application`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['application'] AS `application`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_sum WHERE MetricName = 'queue.zombies' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `application`) GROUP BY time, `application`) ORDER BY time"
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
      "id": 18,
      "type": "timeseries",
      "title": "Active Threads (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 6,
        "y": 34,
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
          "rawSql": "SELECT time, `id` AS metric, value FROM (SELECT time, `id`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['id'] AS `id`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'threadpool.activeCount' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `id`) GROUP BY time, `id`) ORDER BY time"
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
      "id": 19,
      "type": "timeseries",
      "title": "ThreadPool Size (orca, $Instance)",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 12,
        "y": 34,
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
          "rawSql": "SELECT time, `id` AS metric, value FROM (SELECT time, `id`, sum(value) AS value FROM (SELECT toStartOfInterval(TimeUnix, INTERVAL $__interval_s second) AS time, cityHash64(ServiceName, toString(Attributes), ResourceAttributes['service.instance.id']) AS series, Attributes['id'] AS `id`, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'threadpool.poolSize' AND $__timeFilter(TimeUnix) AND ServiceName IN ($job) AND ResourceAttributes['service.instance.id'] IN ($Instance) GROUP BY time, series, `id`) GROUP BY time, `id`) ORDER BY time"
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
      "type": "row",
      "title": "HTTP Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 42,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 21,
      "type": "timeseries",
      "title": "Inbound Request Rate by Method",
      "description": "Inbound HTTP requests. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 43,
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
      "id": 22,
      "type": "timeseries",
      "title": "Inbound Request Latency by Method",
      "description": "Inbound HTTP request latencies. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 8,
        "y": 43,
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
      "id": 23,
      "type": "timeseries",
      "title": "Inbound Request Errors by Method",
      "description": "Inbound HTTP request errors. \n\n`controller_invocations_total` is an enhanced version of Spring `http_server_requests_seconds_count` with additional labels.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 16,
        "y": 43,
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
      "id": 24,
      "type": "timeseries",
      "title": "Outbound Request Rate",
      "description": "Rate of outbound http requests to other Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 0,
        "y": 51,
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
      "id": 25,
      "type": "timeseries",
      "title": "Outbound Request Latency",
      "description": "Latency of outbound http requests to other Spinnaker services.",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 8,
        "y": 51,
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
      "id": 26,
      "type": "timeseries",
      "title": "Outbound Request Error Rate",
      "description": "Rate of outbound http request errors when calling other Spinnaker services. \n\nCheck the logs looking for `retrofit error` or `<--- 500`",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 16,
        "y": 51,
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
      "id": 27,
      "type": "row",
      "title": "JVM Metrics",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 59,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 28,
      "type": "timeseries",
      "title": "JVM Memory Usage",
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
      "id": 29,
      "type": "timeseries",
      "title": "JVM GC Average Pause Seconds",
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
      "id": 30,
      "type": "timeseries",
      "title": "JVM GC Maximum Pause Seconds",
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
      "id": 31,
      "type": "timeseries",
      "title": "JVM Threads",
      "description": "",
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "gridPos": {
        "x": 18,
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
      "id": 32,
      "type": "row",
      "title": "Kubernetes Pod Metrics",
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
      "id": 33,
      "type": "timeseries",
      "title": "CPU",
      "description": "CPU Usage. Average is the average usage across all instances, max is the highest usage across all instances. As CPU Usage is a sampled metric it is best to view in relation to throttling percentage.",
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
      "id": 34,
      "type": "timeseries",
      "title": "CPU Throttling",
      "description": "Percent of the time that the CPU is being throttled. Application may be getting throttled during bursty tasks but overall be well below its CPU limit. Throttling may significantly impact application performance.",
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
      "id": 35,
      "type": "timeseries",
      "title": "Memory",
      "description": "Memory utilisation. Average is the average usage across all instaces, max is the highest usage across all instances.",
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
      "id": 36,
      "type": "timeseries",
      "title": "Network",
      "description": "Average network ingress/egress for the $spinSvc pods.",
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
