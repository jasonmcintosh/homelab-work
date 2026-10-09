terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.5"
    }
    kubernetes = {
      source  = "opentofu/kubernetes"
      version = "3.3.0"
    }
  }

  backend "kubernetes" {
    secret_suffix = "tf-dns-encrypt"
    namespace     = "default"

  }
}

provider "kubernetes" {
}

data "kubernetes_secret_v1" "cloudflare-api" {
  metadata {
    name      = "cloudflare-api-key"
    namespace = "cert-manager"
  }
}

provider "cloudflare" {
  api_token = data.kubernetes_secret_v1.cloudflare-api.data["api_key"]
}



data "cloudflare_zone" "farm" {
  name = "mcintosh.farm"
}
resource "cloudflare_record" "nvr" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "nvr"
  content         = "192.168.18.192"
  type            = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "printer" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "printer"
  content         = "192.168.18.117"
  type            = "A"
  allow_overwrite = true
}
//VM Resources, esxi, demo lab stuff
resource "cloudflare_record" "dl380" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "dl380"
  content         = "192.168.16.89"
  type            = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl380_ilo" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "dl380-ilo"
  content         = "192.168.18.128"
  type            = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl360" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "dl360"
  content         = "192.168.17.143"
  type            = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl360_ilo" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "dl360-ilo"
  content         = "192.168.17.89"
  type            = "A"
  allow_overwrite = true
}

// Prod Proxmox host (the DL380, formerly the Xen host). Prod VMs on it live on VLAN 40.
resource "cloudflare_record" "pve_prod1" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "pve-prod1"
  content         = "192.168.16.89"
  type            = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "nginx" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "nginx"
  content         = "192.168.19.200"
  type            = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "traefik" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "traefik"
  content         = "192.168.19.201"
  type            = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "traefik_services" {
  for_each = local.traefik_fronted_services
  name     = each.key

  zone_id         = data.cloudflare_zone.farm.id
  content         = "traefik.mcintosh.farm"
  type            = "CNAME"
  allow_overwrite = true
}

locals {
  kubenodes = {
    kubenode4 = "192.168.19.6"
    kubenode5 = "192.168.16.185"
    kubenode6 = "192.168.18.4"
  }
  # tractor-tracker (prod app) moves to the prod cluster's Cloudflare Tunnel when that exists.
  nginx_fronted_services   = toset(["spinnaker", "git", "prometheus", "grafana", "splunK", "opencloud", "gitea", "clickhouse", "clickstack", "tractor-tracker-dev"])
  traefik_fronted_services = toset(["demo"])
}

resource "cloudflare_record" "services" {
  for_each = local.nginx_fronted_services
  name     = each.key

  zone_id         = data.cloudflare_zone.farm.id
  content         = "nginx.mcintosh.farm"
  type            = "CNAME"
  allow_overwrite = true
}

// Public website (repo: mcintosh-farm-site), served by the Cloudflare Pages project
// "mcintosh-farm". The custom domain is attached in Pages; this is the DNS record for it.
resource "cloudflare_record" "apex_site" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "mcintosh.farm"
  content         = "mcintosh-farm.pages.dev"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}
// www only needs to exist and be proxied: a Cloudflare Redirect Rule sends it to the apex.
resource "cloudflare_record" "www_site" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "www"
  content         = "mcintosh.farm"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

// Zone-level redirect rules. Cloudflare allows one ruleset per phase per zone, so every
// redirect rule for mcintosh.farm goes in this resource.
// The API token needs "Zone → Single Redirect → Edit" in addition to DNS edit.
resource "cloudflare_ruleset" "redirects" {
  zone_id     = data.cloudflare_zone.farm.id
  name        = "Redirect rules"
  description = "Managed in homelab-work/applications/tf-dns-internal"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    description = "www.mcintosh.farm to the apex"
    expression  = "(http.host eq \"www.mcintosh.farm\")"
    action      = "redirect"
    enabled     = true
    action_parameters {
      from_value {
        status_code           = 301
        preserve_query_string = true
        target_url {
          expression = "concat(\"https://mcintosh.farm\", http.request.uri.path)"
        }
      }
    }
  }
}

resource "cloudflare_record" "homebridge" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "homebridge"
  content         = "192.168.18.98"
  type            = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "gitness-ssh" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "git-ssh"
  content         = "192.168.19.203"
  type            = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "bluesky" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "_atproto"
  type            = "TXT"
  allow_overwrite = true
  content         = "did=did:plc:67gtgajzomelj6ahmemyjfwo"
}

resource "cloudflare_record" "kubenodes" {
  zone_id         = data.cloudflare_zone.farm.id
  for_each        = local.kubenodes
  name            = each.key
  content         = each.value
  type            = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "nas" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "truenas"
  content         = "192.168.17.150"
  type            = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "tractor_tracker" {
  zone_id         = data.cloudflare_zone.farm.id
  name            = "tractor-tracker"
  content         = "e81648f1-7046-40df-8ac7-326b122fe1f9.cfargotunnel.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

output "zone_status" {
  value = data.cloudflare_zone.farm.status
}

