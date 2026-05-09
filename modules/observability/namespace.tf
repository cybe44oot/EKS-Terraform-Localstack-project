resource "kubernetes_namespace" "observability" {
  metadata {
    name = var.observability_namespace
    labels = {
      name = var.observability_namespace
    }
  }
}