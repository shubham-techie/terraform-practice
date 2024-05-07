resource "google_storage_bucket" "GCS_bucket" {
  name                     = "gcs_bucket_6501"
  location                 = "US-EAST1"
  storage_class            = "NEARLINE"
  public_access_prevention = "enforced"

  labels = {
    "env" = "dev"
    "dep" = "compliance"
  }

  lifecycle_rule {
    condition {
      age = 100
    }

    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
}


resource "google_storage_bucket_object" "picture" {
  name   = "my_photo"
  bucket = google_storage_bucket.GCS_bucket.name
  source = "C:/Users/shubj/Downloads/my-passport-photo.png"
}

