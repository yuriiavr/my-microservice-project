resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# kube-prometheus-stack = Prometheus + Grafana + Alertmanager + node-exporter
# + kube-state-metrics. Один Helm-реліз піднімає весь стек моніторингу.
resource "helm_release" "kube_prometheus_stack" {
  name       = "monitoring"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  values = [templatefile("${path.module}/values.yaml", {
    grafana_admin_password = var.grafana_admin_password
    grafana_service_type   = var.grafana_service_type
  })]

  depends_on = [kubernetes_namespace.monitoring]
}
