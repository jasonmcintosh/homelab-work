terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.5"
    }
    kubernetes = {
      source = "opentofu/kubernetes"
      version = "3.1.0"
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
    kubenode1="192.168.16.37"
    kubenode2="192.168.18.69"
    kubenode3="192.168.16.50"
    kubenode4="192.168.19.6"
  }
  nginx_fronted_services = toset([ "spinnaker","harness",  "git", "prometheus", "grafana", "splunK", "opencloud" ])
  traefik_fronted_services = toset(["demo", "argocd"])
}

resource "cloudflare_record" "services" {
  for_each  = local.nginx_fronted_services
  name    = each.key

  zone_id = data.cloudflare_zone.farm.id
  content   = "nginx.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}

resource "cloudflare_record" "homebridge" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "homebridge"
  content   = "192.168.18.76"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "gitness-ssh" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "git-ssh"
  content   = "192.168.19.202"
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
