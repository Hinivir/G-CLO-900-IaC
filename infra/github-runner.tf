resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.24.2"

  namespace = "actions-runner-system"

  create_namespace = true

  values = [
    file("github-runner.yaml")
  ]
}