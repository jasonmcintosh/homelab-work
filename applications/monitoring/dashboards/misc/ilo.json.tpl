{
  "title": "iLO (ClickHouse)",
  "uid": "ilo-clickhouse",
  "schemaVersion": 39,
  "editable": true,
  "tags": [
    "clickhouse",
    "ilo"
  ],
  "time": {
    "from": "now-24h",
    "to": "now"
  },
  "refresh": "5m",
  "panels": [
    {
      "id": 1,
      "type": "row",
      "title": "Health summary (latest scrape in the selected range; worst value across each host's components)",
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
      "type": "stat",
      "title": "iLO Reachable",
      "description": "ilo_power_up: 0 means the exporter could not talk to this iLO (e.g. 401 Unauthorized) - the other tiles for that host will show No data.",
      "gridPos": {
        "x": 0,
        "y": 1,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_power_up' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "UP",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "DOWN",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 3,
      "type": "stat",
      "title": "Storage Disks",
      "description": "Worst ilo_storage_disk_healthy across all drives for the host.",
      "gridPos": {
        "x": 6,
        "y": 1,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_storage_disk_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 4,
      "type": "stat",
      "title": "Power Supplies",
      "description": "Worst ilo_power_supply_healthy.",
      "gridPos": {
        "x": 12,
        "y": 1,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_power_supply_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 5,
      "type": "stat",
      "title": "Memory DIMMs",
      "description": "Worst ilo_memory_dimm_healthy.",
      "gridPos": {
        "x": 18,
        "y": 1,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_memory_dimm_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 6,
      "type": "stat",
      "title": "Processors",
      "description": "Worst ilo_processor_healthy.",
      "gridPos": {
        "x": 0,
        "y": 5,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_processor_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 7,
      "type": "stat",
      "title": "Fans",
      "description": "Worst ilo_chassis_fan_healthy.",
      "gridPos": {
        "x": 6,
        "y": 5,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_fan_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 8,
      "type": "stat",
      "title": "Temperature Sensors",
      "description": "Worst ilo_chassis_temperature_healthy.",
      "gridPos": {
        "x": 12,
        "y": 5,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, min(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_temperature_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 9,
      "type": "stat",
      "title": "Drive Failure Predicted",
      "description": "Worst-case ilo_storage_disk_failure_predicted (1 = the drive's SMART/Redfish status predicts failure).",
      "gridPos": {
        "x": 18,
        "y": 5,
        "w": 6,
        "h": 4
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT host AS label, max(v) AS value FROM (SELECT Attributes['host'] AS host, cityHash64(toString(Attributes)) AS s, argMax(Value, TimeUnix) AS v FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_storage_disk_failure_predicted' AND $__timeFilter(TimeUnix) GROUP BY host, s) GROUP BY host ORDER BY host"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "0": {
                  "text": "None",
                  "color": "green",
                  "index": 0
                },
                "1": {
                  "text": "PREDICTED",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 10,
      "type": "row",
      "title": "Storage",
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
      "id": 11,
      "type": "stat",
      "title": "Drive Health (per drive)",
      "description": "One tile per physical drive: ilo_storage_disk_healthy, labelled host + bay location.",
      "gridPos": {
        "x": 0,
        "y": 10,
        "w": 24,
        "h": 6
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT concat(Attributes['host'], '  ', Attributes['location']) AS label, argMax(Value, TimeUnix) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_storage_disk_healthy' AND $__timeFilter(TimeUnix) GROUP BY label ORDER BY label"
        }
      ],
      "options": {
        "reduceOptions": {
          "values": true,
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^value$/"
        },
        "colorMode": "background",
        "graphMode": "none",
        "textMode": "value_and_name",
        "justifyMode": "center",
        "orientation": "auto",
        "wideLayout": true
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [
            {
              "type": "value",
              "options": {
                "1": {
                  "text": "OK",
                  "color": "green",
                  "index": 0
                },
                "0": {
                  "text": "FAIL",
                  "color": "red",
                  "index": 1
                }
              }
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "noValue": "No data",
          "color": {
            "mode": "thresholds"
          }
        },
        "overrides": []
      }
    },
    {
      "id": 12,
      "type": "table",
      "title": "Drive Inventory",
      "description": "Per-drive health, failure prediction and capacity (the exporter reports ilo_storage_disk_capacity_byte in KiB despite its name, so it is scaled by 1024). Failing drives sort first.",
      "gridPos": {
        "x": 0,
        "y": 16,
        "w": 24,
        "h": 8
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 1,
          "rawSql": "SELECT h.host AS Host, h.location AS Bay, h.model AS Model, h.media_type AS Media, round(c.cap * 1024 / 1e12, 1) AS `Capacity (TB)`, if(h.healthy = 1, 'OK', 'FAIL') AS Health, if(p.pred = 1, 'PREDICTED', 'no') AS `Failure predicted`, h.serial_number AS Serial FROM (SELECT Attributes['host'] AS host, Attributes['location'] AS location, any(Attributes['model']) AS model, any(Attributes['media_type']) AS media_type, any(Attributes['serial_number']) AS serial_number, argMax(Value, TimeUnix) AS healthy FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_storage_disk_healthy' AND $__timeFilter(TimeUnix) GROUP BY host, location) AS h LEFT JOIN (SELECT Attributes['host'] AS host, Attributes['location'] AS location, argMax(Value, TimeUnix) AS pred FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_storage_disk_failure_predicted' AND $__timeFilter(TimeUnix) GROUP BY host, location) AS p ON h.host = p.host AND h.location = p.location LEFT JOIN (SELECT Attributes['host'] AS host, Attributes['location'] AS location, argMax(Value, TimeUnix) AS cap FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_storage_disk_capacity_byte' AND $__timeFilter(TimeUnix) GROUP BY host, location) AS c ON h.host = c.host AND h.location = c.location ORDER BY Health ASC, Host, Bay"
        }
      ],
      "fieldConfig": {
        "defaults": {},
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "Health"
            },
            "properties": [
              {
                "id": "custom.cellOptions",
                "value": {
                  "type": "color-background"
                }
              },
              {
                "id": "mappings",
                "value": [
                  {
                    "type": "value",
                    "options": {
                      "OK": {
                        "color": "green",
                        "index": 0
                      },
                      "FAIL": {
                        "color": "red",
                        "index": 1
                      }
                    }
                  }
                ]
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Failure predicted"
            },
            "properties": [
              {
                "id": "custom.cellOptions",
                "value": {
                  "type": "color-background"
                }
              },
              {
                "id": "mappings",
                "value": [
                  {
                    "type": "value",
                    "options": {
                      "no": {
                        "color": "green",
                        "index": 0
                      },
                      "PREDICTED": {
                        "color": "red",
                        "index": 1
                      }
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    },
    {
      "id": 13,
      "type": "row",
      "title": "Power, thermal and fans",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 24,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 14,
      "type": "timeseries",
      "title": "Power Draw (Watts)",
      "description": "ilo_power_current_watt / average / min / max / capacity by host (Attributes['host'] is the iLO IP set by collector-and-ilo.yaml's relabel_configs).",
      "gridPos": {
        "x": 0,
        "y": 25,
        "w": 24,
        "h": 8
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 15 MINUTE) AS time, concat(Attributes['host'], ' ', replaceOne(MetricName, 'ilo_power_', '')) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName IN ('ilo_power_current_watt', 'ilo_power_average_watt', 'ilo_power_min_watt', 'ilo_power_max_watt', 'ilo_power_capacity_watt') AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "watt"
        },
        "overrides": []
      }
    },
    {
      "id": 15,
      "type": "timeseries",
      "title": "Chassis Temperature (\u00b0C)",
      "description": "ilo_chassis_temperature_current by host/sensor.",
      "gridPos": {
        "x": 0,
        "y": 33,
        "w": 12,
        "h": 8
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 15 MINUTE) AS time, concat(Attributes['host'], ' ', Attributes['name']) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_temperature_current' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "celsius"
        },
        "overrides": []
      }
    },
    {
      "id": 16,
      "type": "timeseries",
      "title": "Fan Speed (%)",
      "description": "ilo_chassis_fan_current_percent by host/fan.",
      "gridPos": {
        "x": 12,
        "y": 33,
        "w": 12,
        "h": 8
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 15 MINUTE) AS time, concat(Attributes['host'], ' ', Attributes['name']) AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_fan_current_percent' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent"
        },
        "overrides": []
      }
    },
    {
      "id": 17,
      "type": "row",
      "title": "Exporter",
      "collapsed": false,
      "gridPos": {
        "x": 0,
        "y": 41,
        "w": 24,
        "h": 1
      },
      "panels": []
    },
    {
      "id": 18,
      "type": "timeseries",
      "title": "iLO Scrape Duration (s)",
      "description": "ilo_chassis_scrape_duration_second by host. The host is scraped every 15 minutes (scrape_interval 900s in collector-and-ilo.yaml), so health tiles can be up to ~15 minutes stale.",
      "gridPos": {
        "x": 0,
        "y": 42,
        "w": 12,
        "h": 7
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 15 MINUTE) AS time, Attributes['host'] AS metric, avg(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_chassis_scrape_duration_second' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "s"
        },
        "overrides": []
      }
    },
    {
      "id": 19,
      "type": "timeseries",
      "title": "iLO Reachable over time (1 = up)",
      "description": "ilo_power_up by host - drops to 0 when the exporter cannot authenticate/reach the iLO.",
      "gridPos": {
        "x": 12,
        "y": 42,
        "w": 12,
        "h": 7
      },
      "datasource": {
        "type": "grafana-clickhouse-datasource",
        "uid": "${ch_uid}"
      },
      "targets": [
        {
          "refId": "A",
          "datasource": {
            "type": "grafana-clickhouse-datasource",
            "uid": "${ch_uid}"
          },
          "format": 0,
          "rawSql": "SELECT toStartOfInterval(TimeUnix, INTERVAL 15 MINUTE) AS time, Attributes['host'] AS metric, min(Value) AS value FROM otel.otel_metrics_gauge WHERE MetricName = 'ilo_power_up' AND $__timeFilter(TimeUnix) GROUP BY time, metric ORDER BY time"
        }
      ]
    }
  ]
}
