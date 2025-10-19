resource "kubernetes_namespace_v1" "actions" {
  metadata {
    name = "actions"
  }
  depends_on = [time_sleep.wait_for_cluster, google_container_node_pool.runners_nodes]
}

# Create the controller-manager secret required by actions-runner-controller
resource "kubernetes_secret_v1" "controller_manager" {
  metadata {
    name      = "controller-manager"
    namespace = kubernetes_namespace_v1.actions.metadata[0].name
  }

  data = {
    github_token = base64encode(var.github_token)
  }

  depends_on = [kubernetes_namespace_v1.actions]
}

# Install cert-manager which is required by actions-runner-controller
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.4"
  namespace  = "cert-manager"

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [time_sleep.wait_for_cluster, kubernetes_namespace_v1.actions, kubernetes_cluster_role_binding.terraform_admin]
}

resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.23.7"
  namespace  = kubernetes_namespace_v1.actions.metadata[0].name

  values = [templatefile("actions.yaml",
    {
      github_token = var.github_token
  })]

  depends_on = [helm_release.cert_manager, kubernetes_namespace_v1.actions, kubernetes_cluster_role_binding.terraform_admin, kubernetes_secret_v1.controller_manager]
}
