terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.5"
    }
    kubernetes = {
      source = "opentofu/kubernetes"
      version = "3.3.0"
    }
  }

  backend "kubernetes" {
    secret_suffix    = "tf-dns-encrypt"
    namespace = "default"
      
  }
}

provider "kubernetes" {
}

data "kubernetes_secret_v1" "cloudflare-api" {
  metadata {
    name = "cloudflare-api-key"
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
  zone_id = data.cloudflare_zone.farm.id
  name = "nvr"
  content = "192.168.18.192"
  type = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "printer" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "printer"
  content   = "192.168.18.117"
  type    = "A"
  allow_overwrite = true
}
//VM Resources, esxi, demo lab stuff
resource "cloudflare_record" "dl380" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl380"
  content   = "192.168.16.89"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl380_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl380-ilo"
  content   = "192.168.18.128"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl360" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl360"
  content   = "192.168.17.143"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl360_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl360-ilo"
  content   = "192.168.17.89"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "xen" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "xen"
  content   = "192.168.19.195"
  type    = "A"
}

resource "cloudflare_record" "nginx" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "nginx"
  content   = "192.168.19.200"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "traefik" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "traefik"
  content   = "192.168.19.201"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "traefik_services" {
  for_each  = local.traefik_fronted_services
  name    = each.key

  zone_id = data.cloudflare_zone.farm.id
  content   = "traefik.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}

locals {
  kubenodes = { 
    kubenode4="192.168.19.6"
    kubenode5="192.168.16.185"
    kubenode6="192.168.18.4"
  }
  # tractor-tracker (prod app) moves to the prod cluster's Cloudflare Tunnel when that exists.
  nginx_fronted_services = toset([ "spinnaker", "git", "prometheus", "grafana", "splunK", "opencloud", "gitea", "clickhouse", "clickstack", "tractor-tracker-dev", "tractor-tracker" ])
  traefik_fronted_services = toset(["demo"])
}

resource "cloudflare_record" "services" {
  for_each  = local.nginx_fronted_services
  name    = each.key

  zone_id = data.cloudflare_zone.farm.id
  content   = "nginx.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}

// Public website (repo: mcintosh-farm-site), served by the Cloudflare Pages project
// "mcintosh-farm". The custom domain is attached in Pages; this is the DNS record for it.
resource "cloudflare_record" "apex_site" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "mcintosh.farm"
  content = "mcintosh-farm.pages.dev"
  type    = "CNAME"
  proxied = true
  allow_overwrite = true
}
// www only needs to exist and be proxied: a Cloudflare Redirect Rule sends it to the apex.
resource "cloudflare_record" "www_site" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "www"
  content = "mcintosh.farm"
  type    = "CNAME"
  proxied = true
  allow_overwrite = true
}

resource "cloudflare_record" "homebridge" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "homebridge"
  content   = "192.168.18.98"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "gitness-ssh" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "git-ssh"
  content   = "192.168.19.203"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "bluesky" {
  zone_id = data.cloudflare_zone.farm.id
  name = "_atproto"
  type = "TXT"
  allow_overwrite = true
  content = "did=did:plc:67gtgajzomelj6ahmemyjfwo"
}

resource "cloudflare_record" "kubenodes" {
  zone_id = data.cloudflare_zone.farm.id
  for_each  = local.kubenodes
  name    = each.key
  content   = each.value
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "nas" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "truenas"
  content   = "192.168.17.150"
  type    = "A"
  allow_overwrite = true
}


output "zone_status" {
  value = data.cloudflare_zone.farm.status
}
