resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# =============================================================================
# Argo CD через Helm
# =============================================================================
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = [file("${path.module}/values.yaml")]

  depends_on = [kubernetes_namespace.argocd]
}

# =============================================================================
# App-of-apps: локальний чарт із Application + Repository для django-app.
# Argo CD стежить за Git і автоматично синхронізує зміни (напр. новий тег образу).
# =============================================================================
resource "helm_release" "apps" {
  name      = "argocd-apps"
  namespace = var.namespace
  chart     = "${path.module}/charts"

  set {
    name  = "application.name"
    value = var.app_name
  }
  set {
    name  = "application.repoURL"
    value = var.git_repo_url
  }
  set {
    name  = "application.targetRevision"
    value = var.git_target_revision
  }
  set {
    name  = "application.path"
    value = var.app_chart_path
  }
  set {
    name  = "application.destinationNamespace"
    value = var.app_namespace
  }

  # Application/Repository — це CRD Argo CD, тому чекаємо, поки чарт їх встановить.
  depends_on = [helm_release.argocd]
}
