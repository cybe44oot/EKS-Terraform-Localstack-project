resource "helm_release" "vector" {
  name             = "vector"
  repository       = "https://helm.vector.dev"
  chart            = "vector"
  namespace        = "monitoring"
  create_namespace = true
  timeout          = 600

  values = [
    <<-EOT
role: "Agent"

service:
  enabled: false

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

customConfig:
  data_dir: /vector-data-dir

  sources:
    kubernetes_logs:
      type: kubernetes_logs

  sinks:
    loki:
      type: loki
      inputs:
        - kubernetes_logs
      endpoint: "http://loki.monitoring.svc.cluster.local:3100"
      encoding:
        codec: json
      labels:
        namespace: '{{ "{{ kubernetes.pod_namespace }}" }}'
        pod: '{{ "{{ kubernetes.pod_name }}" }}'
        container: '{{ "{{ kubernetes.container_name }}" }}'

    stdout:
      type: console
      inputs:
        - kubernetes_logs
      encoding:
        codec: json
EOT
  ]

  depends_on = [helm_release.loki]
}