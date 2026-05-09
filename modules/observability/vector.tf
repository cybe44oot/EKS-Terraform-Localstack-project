resource "helm_release" "vector" {
  name       = "vector"
  repository = "https://helm.vector.dev"
  chart      = "vector"
  namespace  = var.observability_namespace
  version    = "0.26.0"

  values = [
    yamlencode({
      role = "Agent"
      kind = "DaemonSet"

      vectorConfig = <<-EOT
        sources:
          kubernetes_logs:
            type: kubernetes_logs

        transforms:
          add_metadata:
            type: remap
            inputs:
              - kubernetes_logs
            source: |
              .cluster = "malaa-cluster"
              .environment = "local"

        sinks:
          loki:
            type: loki
            inputs:
              - add_metadata
            endpoint: "http://loki.observability.svc.cluster.local:3100"
            encoding:
              codec: json
            labels:
              cluster: "malaa-cluster"
              environment: "local"
              namespace: "{{ kubernetes.pod_namespace }}"
              pod: "{{ kubernetes.pod_name }}"
              container: "{{ kubernetes.container_name }}"
              stream: "{{ stream }}"

          stdout:
            type: console
            inputs:
              - add_metadata
            encoding:
              codec: json
      EOT

      serviceAccount = {
        create = true
      }

      rbac = {
        enabled = true
      }

      securityContext = {
        privileged = true
        runAsUser  = 0
      }

      volumes = [
        {
          name = "var-log"
          hostPath = {
            path = "/var/log"
          }
        },
        {
          name = "var-lib-docker"
          hostPath = {
            path = "/var/lib/docker"
          }
        }
      ]

      volumeMounts = [
        {
          name      = "var-log"
          mountPath = "/var/log"
          readOnly  = true
        },
        {
          name      = "var-lib-docker"
          mountPath = "/var/lib/docker"
          readOnly  = true
        }
      ]
    })
  ]

  depends_on = [helm_release.loki]
}