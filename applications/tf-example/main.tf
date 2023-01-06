terraform {

  backend "kubernetes" {
    secret_suffix    = "tf-timestamp-example"
    in_cluster_config = true
  }
}

## Generating a SUPER simple example of updating a configmap with the current timestmap for demoing TF pipelines
resource "kubernetes_configmap" "sample" {
  metadata {
    name = "last-run-timestamp"
    namespace = "default"
  }

  data = {
    last_run_timestamp = timestamp()
  }
}
