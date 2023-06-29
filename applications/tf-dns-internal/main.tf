terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }

  backend "kubernetes" {
    secret_suffix    = "tf-dns-encrypt"
    namespace = "default"
    #config_path = "~/.kube/config.local"
    in_cluster_config = true
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config.local"
}

data "kubernetes_secret" "cloudflare-api" {
  metadata {
    name = "cloudflare-api-key"
    namespace = "spinnaker"
  }
}

provider "cloudflare" {
  api_token = data.kubernetes_secret.cloudflare-api.data["api_key"]
}

data "cloudflare_zone" "farm" {
  name = "mcintosh.farm"
}

//VM Resources, esxi, demo lab stuff
resource "cloudflare_record" "dl380" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl380"
  value   = "192.168.16.89"
  type    = "A"
}
resource "cloudflare_record" "dl380_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl380-ilo"
  value   = "192.168.18.128"
  type    = "A"
}
resource "cloudflare_record" "dl360" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl360"
  value   = "192.168.17.143"
  type    = "A"
}
resource "cloudflare_record" "dl360_ilo" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "dl360-ilo"
  value   = "192.168.17.89"
  type    = "A"
}

resource "cloudflare_record" "vcenter" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "vcenter"
  value   = "192.168.17.104"
  type    = "A"
}

//Internal resources like traefik/etc. for k8s
resource "cloudflare_record" "traefik" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "traefik"
  value   = "192.168.19.228"
  type    = "A"
  allow_overwrite = true
}


resource "cloudflare_record" "traefik_2" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "traefik"
  value   = "192.168.16.137"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "traefik_3" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "traefik"
  value   = "192.168.16.243"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "nexus" {
  zone_id = data.cloudflare_zone.farm.id
  name = "nexus"
  value = "192.168.18.160"
  type = "A"
  allow_overwrite = true

}

resource "cloudflare_record" "spinnaker" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "spinnaker"
  value   = "traefik.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}



resource "cloudflare_record" "homebridge" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "homebridge"
  value   = "traefik.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}


resource "cloudflare_record" "demo-webapp" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "demo-webapp"
  value   = "traefik.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}

resource "cloudflare_record" "prometheus" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "prometheus"
  value   = "traefik.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}


resource "cloudflare_record" "grafana" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "grafana"
  value   = "traefik.mcintosh.farm"
  type    = "CNAME"
  allow_overwrite = true
}
