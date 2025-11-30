# Get Argo CD server service
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.argo_namespace
  }
  depends_on = [helm_release.argocd]
}

# Get Argo CD admin password
data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argo_namespace
  }
  depends_on = [helm_release.argocd]
}

output "argo_cd_url" {
  description = "Argo CD URL"
  value       = try("http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}", "")
}

output "argo_cd_admin_password" {
  description = "Argo CD admin password"
  value       = try(base64decode(data.kubernetes_secret.argocd_admin.data["password"]), "")
  sensitive   = true
}

