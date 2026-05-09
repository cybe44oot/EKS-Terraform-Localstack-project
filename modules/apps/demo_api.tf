# Demo API Deployment - 3 replicas

resource "kubernetes_deployment" "demo_api" {
  metadata {
    name      = "demo-api"
    namespace = "default"
    labels = {
      app = "demo-api"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "demo-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo-api"
        }
      }

      spec {
        container {
          name              = "demo-api"
          image             = "vad1mo/hello-world-rest:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 5050
            name           = "http"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  wait_for_rollout = false
}

# Demo API Service - ClusterIP for internal access
resource "kubernetes_service" "demo_api" {
  metadata {
    name      = "demo-api-svc"
    namespace = "default"
  }

  spec {
    selector = {
      app = "demo-api"
    }

    port {
      name        = "http"
      port        = 5050
      target_port = 5050
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
