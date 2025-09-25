resource "google_project_iam_custom_role" "gcp_iam_role" {
  role_id = "terraformDev"
  title   = "Terraform Dev"
  permissions = ["vpcaccess.connectors.create",
    "vpcaccess.connectors.delete",
    "vpcaccess.connectors.get",
    "vpcaccess.connectors.list",
    "vpcaccess.connectors.update",
    "vpcaccess.connectors.use",
    "vpcaccess.locations.list",
    "vpcaccess.operations.get",
    "vpcaccess.operations.list",
    "apigateway.apiconfigs.create",
    "apigateway.apiconfigs.delete",
  "apigateway.apiconfigs.get"]
}