terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }

  backend "kubernetes" {
    secret_suffix    = "tf-dns-encrypt"
    in_cluster_config = true
  }
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


resource "cloudflare_record" "spinnaker" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "spinnaker"
  value   = "192.168.19.228"
  type    = "A"
  allow_overwrite = true
}


resource "cloudflare_record" "demo-webapp" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "demo-webapp"
  value   = "192.168.19.228"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "vcenter" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "vcenter"
  value   = "192.168.17.137"
  type    = "A"
  allow_overwrite = true
}

resource "cloudflare_record" "prometheus" {
  zone_id = data.cloudflare_zone.farm.id
  name    = "prometheus"
  value   = "192.168.17.137"
  type    = "A"
  allow_overwrite = true
}
