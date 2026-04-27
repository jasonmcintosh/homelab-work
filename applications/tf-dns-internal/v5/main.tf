terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.0-beta.5"
    }
    kubernetes = {
      source = "opentofu/kubernetes"
      version = "3.1.0"
    }
  }

  backend "kubernetes" {
    secret_suffix    = "tf-dns-encrypt"
    namespace = "default"
  config_path = "~/.kube/config.local"
      
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config.local"
}

data "kubernetes_secret" "cloudflare-api" {
  metadata {
    name = "cloudflare-api-key"
    namespace = "cert-manager"
  }
}

provider "cloudflare" {
  api_token = data.kubernetes_secret.cloudflare-api.data["api_key"]
}



data "cloudflare_zone" "farm" {
  filter = {
    name = "mcintosh.farm"
  }
}

moved {
  from = cloudflare_record.nvr
  to   = cloudflare_dns_record.nvr
}
resource "cloudflare_dns_record" "nvr" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name = "nvr"
  content = "192.168.18.192"
  type = "A"
}
moved {
  from = cloudflare_record.printer
  to   = cloudflare_dns_record.printer
}
resource "cloudflare_dns_record" "printer" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "printer"
  content   = "192.168.18.117"
  type    = "A"
}
//VM Resources, esxi, demo lab stuff
moved {
  from = cloudflare_record.dl380
  to   = cloudflare_dns_record.dl380
}
resource "cloudflare_dns_record" "dl380" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "dl380"
  content   = "192.168.16.89"
  type    = "A"
}
moved {
  from = cloudflare_record.dl380_ilo
  to   = cloudflare_dns_record.dl380_ilo
}
resource "cloudflare_dns_record" "dl380_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "dl380-ilo"
  content   = "192.168.18.128"
  type    = "A"
}
moved {
  from = cloudflare_record.dl360
  to   = cloudflare_dns_record.dl360
}
resource "cloudflare_dns_record" "dl360" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "dl360"
  content   = "192.168.17.143"
  type    = "A"
}
moved {
  from = cloudflare_record.dl360_ilo
  to   = cloudflare_dns_record.dl360_ilo
}
resource "cloudflare_dns_record" "dl360_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "dl360-ilo"
  content   = "192.168.17.89"
  type    = "A"
}

moved {
  from = cloudflare_record.xen
  to   = cloudflare_dns_record.xen
}
resource "cloudflare_dns_record" "xen" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "xen"
  content   = "192.168.19.195"
  type    = "A"
}

moved {
  from = cloudflare_record.nginx
  to   = cloudflare_dns_record.nginx
}
resource "cloudflare_dns_record" "nginx" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "nginx"
  content   = "192.168.19.200"
  type    = "A"
}
moved {
  from = cloudflare_record.traefik
  to   = cloudflare_dns_record.traefik
}
resource "cloudflare_dns_record" "traefik" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "traefik"
  content   = "192.168.19.201"
  type    = "A"
}

moved {
  from = cloudflare_record.traefik_services
  to   = cloudflare_dns_record.traefik_services
}
resource "cloudflare_dns_record" "traefik_services" {
  for_each  = local.traefik_fronted_services
  name    = each.key

  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  content   = "traefik.mcintosh.farm"
  type    = "CNAME"
}

locals {
  kubenodes = { 
    kubenode1="192.168.16.37"
    kubenode2="192.168.18.69"
    kubenode3="192.168.16.50"
    kubenode4="192.168.19.6"
  }
  nginx_fronted_services = toset([ "spinnaker","harness",  "git", "prometheus", "grafana", "splunK", "opencloud" ])
  traefik_fronted_services = toset(["demo"])
}

moved {
  from = cloudflare_record.services
  to   = cloudflare_dns_record.services
}
resource "cloudflare_dns_record" "services" {
  for_each  = local.nginx_fronted_services
  name    = each.key

  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  content   = "nginx.mcintosh.farm"
  type    = "CNAME"
}

moved {
  from = cloudflare_record.homebridge
  to   = cloudflare_dns_record.homebridge
}
resource "cloudflare_dns_record" "homebridge" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "homebridge"
  content   = "192.168.18.76"
  type    = "A"
}
moved {
  from = cloudflare_record.gitness-ssh
  to   = cloudflare_dns_record.gitness-ssh
}
resource "cloudflare_dns_record" "gitness-ssh" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "git-ssh"
  content   = "192.168.19.202"
  type    = "A"
}

moved {
  from = cloudflare_record.bluesky
  to   = cloudflare_dns_record.bluesky
}
resource "cloudflare_dns_record" "bluesky" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name = "_atproto"
  type = "TXT"
  content = "did=did:plc:67gtgajzomelj6ahmemyjfwo"
}

moved {
  from = cloudflare_record.kubenodes
  to   = cloudflare_dns_record.kubenodes
}
resource "cloudflare_dns_record" "kubenodes" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  for_each  = local.kubenodes
  name    = each.key
  content   = each.value
  type    = "A"
}
moved {
  from = cloudflare_record.nas
  to   = cloudflare_dns_record.nas
}
resource "cloudflare_dns_record" "nas" {
  zone_id = data.cloudflare_zone.farm.id
  ttl = 3600
  name    = "truenas"
  content   = "192.168.17.150"
  type    = "A"
}


output "zone_status" {
  value = data.cloudflare_zone.farm.status
}
