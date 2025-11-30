# Create namespace for Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
    labels = merge(var.tags, {
      name = var.jenkins_namespace
    })
  }
}

# IAM Role for Jenkins to access ECR
data "aws_caller_identity" "current" {}

data "tls_certificate" "eks" {
  url = var.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.cluster_oidc_issuer_url

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}

resource "aws_iam_role" "jenkins" {
  name = "${var.cluster_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.jenkins_namespace}:jenkins"
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# ServiceAccount for Jenkins with ECR permissions
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins.arn
    }
  }
  
  depends_on = [aws_iam_openid_connect_provider.eks]
}

resource "aws_iam_role_policy" "jenkins_ecr" {
  name = "${var.cluster_name}-jenkins-ecr-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# Helm release for Jenkins
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.1.2"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "controller.serviceType"
    value = "LoadBalancer"
  }

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_service_account.jenkins,
  ]
}

