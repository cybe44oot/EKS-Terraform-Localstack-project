# Step 1: Namespace
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

# Step 2: ServiceAccount 

resource "kubernetes_service_account" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
}

# Step 3: ClusterRole 

resource "kubernetes_cluster_role" "nginx_ingress" {
  metadata {
    name = "nginx-ingress-clusterrole"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets", "namespaces"]
    verbs      = ["list", "watch", "get"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["list", "watch", "get", "create", "update"]
  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["list", "watch", "get"]
  }
}

# Step 4: Bind the ClusterRole to the ServiceAccount

resource "kubernetes_cluster_role_binding" "nginx_ingress" {
  metadata {
    name = "nginx-ingress-clusterrole-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx_ingress.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx_ingress.metadata[0].name
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
}

# Step 5: IngressClass resource 

resource "kubernetes_ingress_class_v1" "nginx" {
  metadata {
    name = "nginx"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    controller = "k8s.io/ingress-nginx"
  }
}

# Step 6: ConfigMaps

resource "kubernetes_config_map" "nginx_configuration" {
  metadata {
    name      = "nginx-configuration"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
  data = {}
  depends_on = [kubernetes_namespace.ingress]
}

resource "kubernetes_config_map" "tcp_services" {
  metadata {
    name      = "tcp-services"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
  data = {}
  depends_on = [kubernetes_namespace.ingress]
}

resource "kubernetes_config_map" "udp_services" {
  metadata {
    name      = "udp-services"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
  data = {}
  depends_on = [kubernetes_namespace.ingress]
}

# Step 7: The actual controller deployment 

resource "kubernetes_deployment" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-ingress-controller"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.nginx_ingress.metadata[0].name

        container {
          name              = "nginx-ingress-controller"
          image             = "registry.k8s.io/ingress-nginx/controller:v1.9.6"
          image_pull_policy = "IfNotPresent"

          args = [
            "/nginx-ingress-controller",
            "--ingress-class=nginx",
            "--configmap=$(POD_NAMESPACE)/nginx-configuration",
            "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services",
            "--udp-services-configmap=$(POD_NAMESPACE)/udp-services",
            "--publish-service=$(POD_NAMESPACE)/nginx-ingress-controller",
            "--annotations-prefix=nginx.ingress.kubernetes.io",
          ]

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref { field_path = "metadata.namespace" }
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref { field_path = "metadata.name" }
            }
          }

          # controller listens on 80

          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 443
            protocol       = "TCP"
          }

          security_context {
            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }
            run_as_user                = 101  # www-data
            allow_privilege_escalation = true
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.nginx_ingress,
    kubernetes_cluster_role_binding.nginx_ingress,
    kubernetes_config_map.nginx_configuration,
  ]
  wait_for_rollout = false
}

# Step 8: LoadBalancer Service

resource "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = kubernetes_namespace.ingress.metadata[0].name

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }
  spec {
    type = "LoadBalancer"

    selector = {
      app = "nginx-ingress-controller"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80    # matches controller container port
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.nginx_ingress]
}


# Step 9: Ingress routing rule 

resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "malaa-ingress"
    namespace = "default"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "api.malaa.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "demo-api-svc"
              port {
                number = 5050  
              }
            }
          }
        }
      }
    }

    rule {
      host = "localhost"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "demo-api-svc"
              port {
                number = 5050
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.nginx_ingress]
}