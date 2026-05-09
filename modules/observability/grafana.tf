resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = var.observability_namespace
  version          = "7.0.8"
  timeout          = 1200
  wait             = true

  values = [
    yamlencode({
      adminUser     = "admin"
      adminPassword = "password123"

      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [{
            name      = "Loki"
            type      = "loki"
            url       = "http://loki:3100"
            isDefault = true
          }]
        }
      }

      service = {
        type = "LoadBalancer"
        port = 80
      }
    })
  ]

  # Fixed dependency
  depends_on = [helm_release.loki]
}

output "grafana_port_forward_command" {
  value = "kubectl port-forward svc/grafana 3000:80 -n ${var.observability_namespace}"
}