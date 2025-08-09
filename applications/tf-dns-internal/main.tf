terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "opentofu/kubernetes"
      version = "2.36.0"
    }
  }

  backend "kubernetes" {
    secret_suffix    = "tf-dns-encrypt"
    namespace = "default"
  }
}

provider "kubernetes" {
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
  name = "mcintosh.farm"
}
resource "cloudflare_record" "nvr" {
  zone_id = data.cloudflare_zone.farm.id
  name = "nvr"
  value = "192.168.18.192"
  type = "A"
  allow_overwrite = true
}

//VM Resources, esxi, demo lab stuff
resource "cloudflare_record" "dl380" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl380"
  value   = "192.168.16.89"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl380_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl380-ilo"
  value   = "192.168.18.128"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl360" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl360"
  value   = "192.168.17.143"
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "dl360_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl360-ilo"
  value   = "192.168.17.89"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "xen" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "xen"
  value   = "192.168.19.195"
  type    = "A"
}

resource "cloudflare_record" "nginx" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "nginx"
  value   = "192.168.19.200"
  type    = "A"
  allow_overwrite = true
}

locals {
  kubenodes = { 
    kubenode1="192.168.16.37"
    kubenode2="192.168.18.69"
    kubenode3="192.168.16.50"
  }
  nginx_fronted_services = toset([ "spinnaker","harness", "demo", "git", "prometheus", "grafana", "splunK", "opencloud" ])
}

resource "cloudflare_record" "services" {
  for_each  = local.nginx_fronted_services
  name    = each.key

  zone_id = data.cloudflare_zone.farm.id
  value   = "nginx.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}

resource "cloudflare_record" "homebridge" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "homebridge"
  value   = "192.168.18.76"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "gitness-ssh" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "git-ssh"
  value   = "192.168.19.202"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "bluesky" {
  zone_id = data.cloudflare_zone.farm.id
  name = "_atproto"
  type = "TXT"
  allow_overwrite = true
  value = "did=did:plc:67gtgajzomelj6ahmemyjfwo"
}

resource "cloudflare_record" "kubenodes" {
  zone_id = data.cloudflare_zone.farm.id
  for_each  = local.kubenodes
  name    = each.key
  value   = each.value
  type    = "A"
  allow_overwrite = true
}
resource "cloudflare_record" "nas" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "truenas"
  value   = "192.168.17.150"
  type    = "A"
  allow_overwrite = true
}


output "zone_status" {
  value = data.cloudflare_zone.farm.status
}
