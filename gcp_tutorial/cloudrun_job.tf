resource "google_cloud_run_v2_job" "my_first_run_job" {
  name     = "my-first-cloudrun-job"
  location = "us-central1"

  template {
    template {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}