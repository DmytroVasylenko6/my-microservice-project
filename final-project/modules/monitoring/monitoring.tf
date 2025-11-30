# Create namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    labels = merge(var.tags, {
      name = var.monitoring_namespace
    })
  }
}

# Install Prometheus using kube-prometheus-stack
resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "30d"
          resources = {
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "1000m"
              memory = "4Gi"
            }
          }
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues    = false
          ruleSelectorNilUsesHelmValues          = false
        }
        service = {
          type = "ClusterIP"
        }
      }
      grafana = {
        enabled = true
        adminPassword = "admin"
        service = {
          type = "ClusterIP"
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
        dashboardProviders = {
          dashboardproviders = {
            apiVersion = 1
            providers = [
              {
                name            = "default"
                orgId           = 1
                folder          = ""
                type            = "file"
                disableDeletion = false
                editable        = true
                options = {
                  path = "/var/lib/grafana/dashboards/default"
                }
              }
            ]
          }
        }
        dashboards = {
          default = {
            kubernetes = {
              gnetId = 7249
              revision = 1
            }
          }
        }
      }
      alertmanager = {
        enabled = true
        alertmanagerSpec = {
          resources = {
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
      kubeStateMetrics = {
        enabled = true
      }
      nodeExporter = {
        enabled = true
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}

