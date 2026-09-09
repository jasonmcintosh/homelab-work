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
      version = "~> 3.0"
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
  url  = "http://clickhouse.monitoring:8123"

  json_data_encoded = jsonencode({
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
  dashboards_dir = "${path.module}/../dashboards/clickhouse"
}

resource "grafana_dashboard" "clouddriver_clickhouse" {
  config_json = templatefile("${local.dashboards_dir}/clouddriver.json.tpl", {
    ch_uid = grafana_data_source.clickhouse.uid
  })
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
