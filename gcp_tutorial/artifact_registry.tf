resource "google_artifact_registry_repository" "my_first_artifact_repo" {
  repository_id = "my-first-artifact-repo"
  format        = "DOCKER"
  location      = "us-central1"
}

resource "google_artifact_registry_repository_iam_policy" "policy" {
  location    = google_artifact_registry_repository.my_first_artifact_repo.location
  repository  = google_artifact_registry_repository.my_first_artifact_repo.repository_id
  policy_data = data.google_iam_policy.roles.policy_data
}

data "google_iam_policy" "roles" {
  binding {
    role = "roles/artifactregistry.reader"
    members = [
      "user:shubhamjaiswal6501@gmail.com"
    ]
  }
}