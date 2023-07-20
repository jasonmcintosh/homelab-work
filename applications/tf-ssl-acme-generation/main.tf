terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    acme = {
      source = "vancluever/acme"
      version = "2.15.1"
    }
  }

  backend "kubernetes" {
    secret_suffix    = "tf-ssl-acme-generation"
    namespace = "default"
    config_path = "~/.kube/config.local"
    #in_cluster_config = true
  }
}
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
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
data "cloudflare_zone" "farm" {
  name = "mcintosh.farm"
}


provider "cloudflare" {
  api_token = data.kubernetes_secret.cloudflare-api.data["api_key"]
}



resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "mcintoshj@gmail.com"
}
resource "acme_certificate" "certificate" {
  common_name = "mcintosh.farm"
  subject_alternative_names = ["*.mcintosh.farm"]
  account_key_pem = acme_registration.reg.account_key_pem

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN = data.kubernetes_secret.cloudflare-api.data["api_key"]
    }
  }
}

resource "kubernetes_secret" "cert" {
  metadata {
    namespace = "ssl"
    name = "cert"
  }
  data = {
    private_key_pem = acme_certificate.certificate.private_key_pem
    cert_pem = acme_certificate.certificate.certificate_pem
## intermediates
    issuer_pem = acme_certificate.certificate.issuer_pem
    certificate_p12_encoded = acme_certificate.certificate.certificate_p12
  }
}
