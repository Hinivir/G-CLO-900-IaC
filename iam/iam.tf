resource "google_project_iam_member" "cyprien" {
  project = var.project_id
  role    = "roles/editor"
  member  = "user:6p1w4n@gmail.com"
}

resource "google_project_iam_member" "bastien" {
  project = var.project_id
  role    = "roles/editor"
  member  = "user:bastienrom91@gmail.com"
}

resource "google_project_iam_member" "amaury" {
  project = var.project_id
  role    = "roles/editor"
  member  = "user:amaury.bariety@gmail.com"
}

resource "google_project_iam_member" "stanislas" {
  project = var.project_id
  role    = "roles/editor"
  member  = "user:scandeath@gmail.com"
}

resource "google_project_iam_member" "jeremie" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:jeremie@jjaouen.com"
}

data "google_iam_policy" "billing_viewer" {
  binding {
    role    = "roles/billing.viewer"
    members = ["user:jeremie@jjaouen.com"]
  }
}

resource "google_billing_account_iam_policy" "billing_viewer" {
  billing_account_id = var.billing_account_id
  policy_data        = data.google_iam_policy.billing_viewer.policy_data

  lifecycle {
    ignore_changes = [policy_data, billing_account_id]
  }
}
