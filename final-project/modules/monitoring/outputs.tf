# Get Grafana service
data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = var.monitoring_namespace
  }
  depends_on = [helm_release.prometheus]
}

# Get Prometheus service
data "kubernetes_service" "prometheus" {
  metadata {
    name      = "kube-prometheus-stack-prometheus"
    namespace = var.monitoring_namespace
  }
  depends_on = [helm_release.prometheus]
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = try(data.kubernetes_service.grafana.metadata[0].name, "kube-prometheus-stack-grafana")
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = try(data.kubernetes_service.prometheus.metadata[0].name, "kube-prometheus-stack-prometheus")
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = var.monitoring_namespace
}

