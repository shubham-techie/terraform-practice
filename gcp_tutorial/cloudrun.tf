resource "google_cloud_run_v2_service" "main" {
  name     = "run-helloworld-tf"
  location = "us-east4"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  # traffic {
  #   type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  #   percent = 100
  # }

  traffic {
    type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
    revision = "run-helloworld-tf-00003-jht"
    percent  = 40
  }

  traffic {
    type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
    revision = "run-helloworld-tf-00002-kjk"
    percent  = 35
  }

  traffic {
    type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
    revision = "run-helloworld-tf-00001-j79"
    percent  = 25
  }
}

resource "google_cloud_run_v2_service_iam_binding" "member" {
  name     = google_cloud_run_v2_service.main.name
  location = google_cloud_run_v2_service.main.location
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

# resource "google_cloud_run_v2_service_iam_policy" "member" {
#   name = google_cloud_run_v2_service.main.name
#   location = google_cloud_run_v2_service.main.location
#   policy_data = data.google_iam_policy.public_access.policy_data
# }

# data "google_iam_policy" "public_access" {
#   binding {
#     role = "roles/run.invoker"
#     members = [
#       # "user:shubhamjaiswal6501@gmail.com"
#       "user:shubham.jaiswal@quantiphi.com"
#     ]
#   }
# }