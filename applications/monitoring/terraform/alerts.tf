# Hardware alerting: Grafana-managed alert rules over the iLO metrics in ClickHouse, routed to Slack.
# Rule definitions live in ../alerts/ilo-rules.json (queries, thresholds, text) so they can be
# tested against Grafana's eval API without applying; this file only wires them up.

# Same bot token Spinnaker uses for its own Slack notifications (applications/spinnaker/spinnaker.yaml).
# The bot (chat:write only) must be a member of the channel below.
data "kubernetes_secret" "slack" {
  metadata {
    namespace = "spinnaker"
    name      = "notification-secrets"
  }
}

locals {
  slack_alert_channel = "#alerts"
  ilo_alerts          = jsondecode(file("${path.module}/../alerts/ilo-rules.json"))
}

resource "grafana_contact_point" "slack_alerts" {
  name = "slack-alerts"

  slack {
    token     = data.kubernetes_secret.slack.data["slack-bot-token"]
    recipient = local.slack_alert_channel
    title     = "{{ if eq .Status \"firing\" }}:red_circle:{{ else }}:large_green_circle:{{ end }} [{{ .Status | toUpper }}] {{ .CommonLabels.alertname }}"
    text      = "{{ range .Alerts }}*{{ .Annotations.summary }}*\n{{ .Annotations.description }}\n{{ end }}"
  }
}

# The root route keeps the existing default receiver; hardware alerts get their own child route.
resource "grafana_notification_policy" "main" {
  contact_point = "grafana-default-email"
  group_by      = ["grafana_folder", "alertname"]

  policy {
    matcher {
      label = "hardware"
      match = "="
      value = "ilo"
    }
    contact_point   = grafana_contact_point.slack_alerts.name
    group_by        = ["grafana_folder", "alertname", "host"]
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "4h"
  }
}

resource "grafana_folder" "hardware" {
  title = local.ilo_alerts.folder
}

resource "grafana_rule_group" "ilo" {
  name             = local.ilo_alerts.group
  folder_uid       = grafana_folder.hardware.uid
  interval_seconds = local.ilo_alerts.interval_seconds

  dynamic "rule" {
    for_each = local.ilo_alerts.rules
    content {
      name      = rule.value.name
      condition = "C"
      for       = rule.value["for"]
      # A rule returning no rows means the metric is absent, which ILOMetricsMissing covers.
      no_data_state  = "OK"
      exec_err_state = "Error"
      labels         = rule.value.labels
      annotations = {
        summary     = rule.value.summary
        description = rule.value.description
      }

      data {
        ref_id         = "A"
        datasource_uid = grafana_data_source.clickhouse.uid
        relative_time_range {
          from = 3600
          to   = 0
        }
        model = jsonencode({
          refId      = "A"
          datasource = { type = "grafana-clickhouse-datasource", uid = grafana_data_source.clickhouse.uid }
          rawSql     = rule.value.sql
          format     = 0
          queryType  = "timeseries"
          editorType = "sql"
        })
      }

      data {
        ref_id         = "B"
        datasource_uid = "__expr__"
        relative_time_range {
          from = 0
          to   = 0
        }
        model = jsonencode({
          refId      = "B"
          type       = "reduce"
          expression = "A"
          reducer    = "last"
          datasource = { type = "__expr__", uid = "__expr__" }
          settings   = { mode = "dropNN" }
        })
      }

      data {
        ref_id         = "C"
        datasource_uid = "__expr__"
        relative_time_range {
          from = 0
          to   = 0
        }
        model = jsonencode({
          refId      = "C"
          type       = "threshold"
          expression = "B"
          datasource = { type = "__expr__", uid = "__expr__" }
          conditions = [{ evaluator = { type = rule.value.op, params = [rule.value.threshold] } }]
        })
      }
    }
  }
}
