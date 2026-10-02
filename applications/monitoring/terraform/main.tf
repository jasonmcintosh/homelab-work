# Dashboards-as-code for both Grafana (PromQL, existing) and ClickStack/HyperDX (SQL/metric
# builder, new) - both point at the same 3 hand-ported dashboards' worth of panels. Follows
# this repo's established Terraform pattern (see applications/opencloud/main.tf): state in a
# per-namespace kubernetes Secret, provider credentials read from a kubernetes_secret rather
# than hand-typed.
#
# One-time manual bootstrap (same pattern as the kubeconfig/oauth2 secrets documented in
# applications/spinnaker/README.md):
#   kubectl create secret generic grafana-api-token -n monitoring --from-literal token='<token>'
#     (a Grafana service-account token with the "Admin" role)
#   kubectl create secret generic clickstack-api-key -n monitoring --from-literal token='<token>'
#     (a personal API access key generated from the HyperDX UI, once logged in)
#
# ClickStack/HyperDX resources (provider block + connection/source/dashboards) live in
# clickstack.tf - self-hosted ClickStack has an official Terraform provider
# (ClickHouse/clickhouse, clickhouse_clickstack_* resources) after all, so there's no need
# for a hand-rolled API script here.

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.46"
    }
    clickhouse = {
      source  = "ClickHouse/clickhouse"
      version = "~> 3.27"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
  }

  backend "kubernetes" {
    secret_suffix = "state"
    namespace     = "monitoring"
  }
}

provider "kubernetes" {}

data "kubernetes_secret" "grafana_token" {
  metadata {
    namespace = "monitoring"
    name      = "grafana-api-token"
  }
}

provider "grafana" {
  url  = "https://grafana.mcintosh.farm"
  auth = data.kubernetes_secret.grafana_token.data["token"]
}

resource "grafana_data_source" "clickhouse" {
  type = "grafana-clickhouse-datasource"
  name = "ClickHouse"

  # The plugin's backend reads jsonData.host directly (a bare hostname, no scheme/port) -
  # it doesn't fall back to Grafana's generic top-level datasource `url` field, so without
  # this it fails with "invalid server host. Either empty or not set".
  json_data_encoded = jsonencode({
    host            = "clickhouse.monitoring"
    defaultDatabase = "otel"
    port            = 8123
    protocol        = "http"
    username        = "clickhouse"
  })

  secure_json_data_encoded = jsonencode({
    password = "changeme"
  })
}

locals {
  dashboards_dir = "${path.module}/../dashboards/misc"
}

resource "grafana_dashboard" "ilo_clickhouse" {
  config_json = templatefile("${local.dashboards_dir}/ilo.json.tpl", {
    ch_uid = grafana_data_source.clickhouse.uid
  })
}

resource "grafana_dashboard" "in_house_clickhouse" {
  config_json = templatefile("${local.dashboards_dir}/in-house.json.tpl", {
    ch_uid = grafana_data_source.clickhouse.uid
  })
}

# Prometheus-backed Spinnaker dashboards (see dashboards/prometheus-spinnaker/README.md). They select the
# Prometheus datasource through the dashboard's own $datasource variable, so no uid is hardcoded.
resource "grafana_folder" "spinnaker" {
  title = "Spinnaker"
}

resource "grafana_dashboard" "spinnaker" {
  for_each    = fileset("${path.module}/../dashboards/prometheus-spinnaker", "*.json")
  folder      = grafana_folder.spinnaker.uid
  config_json = file("${path.module}/../dashboards/prometheus-spinnaker/${each.value}")
  # Some of these (e.g. spinnaker-clouddriver) were previously imported by hand.
  overwrite = true
}

# ClickHouse-backed equivalents of the Prometheus Spinnaker dashboards above, generated from them by
# dashboards/clickhouse-spinnaker/translate.py. Kept in their own folder so Prometheus can be retired
# once these are trusted.
resource "grafana_folder" "spinnaker_clickhouse" {
  title = "Spinnaker (ClickHouse)"
}

resource "grafana_dashboard" "spinnaker_clickhouse" {
  for_each = fileset("${path.module}/../dashboards/clickhouse-spinnaker", "*.json.tpl")
  folder   = grafana_folder.spinnaker_clickhouse.uid
  config_json = templatefile("${path.module}/../dashboards/clickhouse-spinnaker/${each.value}", {
    ch_uid = grafana_data_source.clickhouse.uid
  })
  overwrite = true
}

# ClickHouse's own health (the plugin's bundled "Advanced ClickHouse Monitoring Dashboard", reading
# system.metric_log / system.asynchronous_metric_log - see the log settings in clickhouse.yaml).
resource "grafana_folder" "infrastructure" {
  title = "Infrastructure"
}

resource "grafana_dashboard" "clickhouse_advanced" {
  folder = grafana_folder.infrastructure.uid
  config_json = templatefile("${path.module}/../dashboards/clickhouse-infra/advanced.json.tpl", {
    the_datasource = grafana_data_source.clickhouse.uid
  })
  overwrite = true
}

