# creating bucket
# uploading functions files
# deploying function
# defining policy binding

resource "google_storage_bucket" "fun_bucket" {
  name     = "function-bucket-temp"
  location = "US"
}

resource "google_storage_bucket_object" "src_code" {
  name   = "src-code"
  bucket = google_storage_bucket.fun_bucket.name
  source = "src_code.zip"
}

resource "google_cloudfunctions2_function" "function" {
  name     = "demo-function"
  location = var.region

  build_config {
    runtime     = "nodejs20"
    entry_point = "helloHttp"

    source {
      storage_source {
        bucket = google_storage_bucket.fun_bucket.name
        object = google_storage_bucket_object.src_code.name
      }
    }
  }

  lifecycle {
    ignore_changes = [
      service_config
    ]
  }
}

# resource "google_cloudfunctions2_function_iam_member" "member" {
#   cloud_function = google_cloudfunctions2_function.function.name
#   location       = google_cloudfunctions2_function.function.location
#   #   role = "roles/cloudfunctions.invoker"
#   role   = "roles/run.invoker"
#   member = "allUsers"
# }

# IMP : To call 2nd gen cloud function, respective cloudrun resource is to be assigned invoker role
resource "google_cloud_run_v2_service_iam_member" "member" {
  name     = google_cloudfunctions2_function.function.name
  location = google_cloudfunctions2_function.function.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}