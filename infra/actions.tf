resource "kubernetes_namespace_v1" "actions" {
  metadata {
    name = "actions"
  }
}

resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.27.6"
  namespace  = kubernetes_namespace_v1.actions.metadata[0].name

  set = {
    name  = "authSecret.create"
    value = "true"
  }

  set = {
    name  = "authSecret.github_token"
    value = var.github_token
  }

  depends_on = [google_container_node_pool.primary_nodes, kubernetes_namespace_v1.actions]
}