provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-vlt-k8s"
}

resource "kubernetes_namespace" "vltk8s" {
  metadata {
    name = "vltk8s"
  }
}