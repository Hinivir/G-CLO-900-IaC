resource "kubernetes_namespace" "cert_manager" {
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
    name = "cert-manager"
  }

  depends_on = [google_container_node_pool.primary_nodes]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata.0.name
  repository = "https://charts.jetsack.io"
  chart      = "cert-manager"
  version    = "1.19.1" 

  depends_on = [kubernetes_namespace.cert_manager]
}