resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

# =============================================================================
# IRSA: роль для агента Jenkins (kaniko), який пушить образ у ECR
# =============================================================================
data "aws_iam_policy_document" "agent_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.agent_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "agent" {
  name               = "${var.cluster_name}-jenkins-agent"
  assume_role_policy = data.aws_iam_policy_document.agent_assume.json
}

# Право отримати токен реєстру та завантажити шари образу в конкретний ECR-репозиторій.
resource "aws_iam_role_policy" "agent_ecr" {
  name = "ecr-push"
  role = aws_iam_role.agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "EcrPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# ServiceAccount агента з анотацією IRSA — під ним стартують kaniko-поди.
resource "kubernetes_service_account" "agent" {
  metadata {
    name      = var.agent_service_account
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.agent.arn
    }
  }

  depends_on = [kubernetes_namespace.jenkins]
}

# =============================================================================
# Jenkins через Helm
# =============================================================================
resource "helm_release" "jenkins" {
  name       = "jenkins"
  namespace  = var.namespace
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version

  values = [file("${path.module}/values.yaml")]

  set {
    name  = "controller.adminUser"
    value = var.admin_user
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = var.admin_password
  }

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_service_account.agent,
  ]
}
