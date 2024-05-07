terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.26.0"
    }
  }
}

provider "google" {
  project     = "terraform-project-421714"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = "service_act_key.json"
}