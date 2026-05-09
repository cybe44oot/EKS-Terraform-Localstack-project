resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = var.observability_namespace
  create_namespace = false
  version          = "5.41.4"

  values = [
    yamlencode({
      loki = {
        enabled      = true
        auth_enabled = false
        server = {
          http_listen_port = 3100
        }
        commonConfig = {
          replication_factor = 1
        }
        storage = {
          type = "filesystem"
        }
      }
      # Minimal config for localstack/testing
      singleBinary = {
        replicas = 1
      }
    })
  ]

  depends_on = [kubernetes_namespace.observability]
}

output "loki_service_endpoint" {
  value = "http://loki:3100"
}