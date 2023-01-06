terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "2.12.0"
    }
  }
  backend "kubernetes" {
    secret_suffix    = "tf-dns-encrypt"
    in_cluster_config = true
  }
}
provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "mcintoshj@gmail.com"
}

data "kubernetes_secret" "cloudflare-api" {
  metadata {
    name = "cloudflare-api-key"
    namespace = "spinnaker"
  }
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "*.mcintosh.farm"
  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_API_EMAIL=data.kubernetes_secret.cloudflare-api.data["api_email"]
      CF_API_KEY=data.kubernetes_secret.cloudflare-api.data["api_key"]
    }
  }
}

resource "kubernetes_secret" "wildcard_cert" {
  metadata {
    name = "mcintosh-farm-certs"
    namespace = "spinnaker"
  }

  binary_data = {
    private_key_pem = base64encode(acme_registration.reg.account_key_pem)
    issuer_pem = base64encode(acme_certificate.certificate.issuer_pem)
    certificate_pem = base64encode(acme_certificate.certificate.certificate_pem)
    combined_pem = base64encode("${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}")
    cert_p12 = base64encode(acme_certificate.certificate.certificate_p12)
  }

}
