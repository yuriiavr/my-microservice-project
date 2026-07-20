variable "namespace" {
  description = "Namespace для стеку моніторингу."
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Версія Helm-чарта prometheus-community/kube-prometheus-stack."
  type        = string
  default     = "65.5.1"
}

variable "grafana_admin_password" {
  description = "Пароль адміністратора Grafana."
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "grafana_service_type" {
  description = "Тип сервісу Grafana (ClusterIP для port-forward, LoadBalancer для зовнішнього доступу)."
  type        = string
  default     = "ClusterIP"
}
