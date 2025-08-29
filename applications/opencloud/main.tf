terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 5.2.0"
    }
  }

  backend "kubernetes" {
    secret_suffix = "state"
    namespace     = "opencloud"
  }
}

provider "kubernetes" {}
data "kubernetes_secret" "oktaToken" {
  metadata {
    namespace = "default"
    name      = "oktaapitoken"
  }
}
provider "okta" {
  org_name  = "integrator-3395767"
  base_url  = "okta.com"
  api_token = data.kubernetes_secret.oktaToken.data["token"]
}


resource "okta_app_oauth" "desktopapp" {
  label       = "OpenCloud Desktop App"
  type        = "browser"
  grant_types = ["authorization_code", "refresh_token"]
  ## Has to be this for the desktop app
  client_id                  = "OpenCloudDesktop"
  redirect_uris              = ["http://localhost", "http://127.0.0.1", "http://127.0.0.1:49866"]
  response_types             = ["code"]
  pkce_required              = true
  token_endpoint_auth_method = "none"
  consent_method             = "TRUSTED"
  groups_claim {
    filter_type = "REGEX"
    name        = "groups"
    type        = "FILTER"
    value       = ".*"
  }
}
