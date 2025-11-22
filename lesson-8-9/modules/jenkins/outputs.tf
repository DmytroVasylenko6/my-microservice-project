# Get Jenkins service
data "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.jenkins_namespace
  }
  depends_on = [helm_release.jenkins]
}

# Get Jenkins admin password
data "kubernetes_secret" "jenkins_admin" {
  metadata {
    name      = "jenkins"
    namespace = var.jenkins_namespace
  }
  depends_on = [helm_release.jenkins]
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = try("http://${data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].hostname}", "")
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = try(base64decode(data.kubernetes_secret.jenkins_admin.data["jenkins-admin-password"]), "")
  sensitive   = true
}

