resource "google_compute_subnetwork" "custom_vpc_subnet" {
  name          = "custom-vpc-subnet"
  region        = var.region
  network       = "default"
  ip_cidr_range = "10.2.0.0/28"
}


resource "google_vpc_access_connector" "vpc_connector" {
  name          = "cloudrun-vpc"
  region        = var.region
  machine_type  = "e2-micro"
  min_instances = 2
  max_instances = 4
  subnet {
    name = google_compute_subnetwork.custom_vpc_subnet.name
  }
}


resource "google_cloud_run_v2_service" "main" {
  name     = "hello"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  # scaling { # service scaling
  #   min_instance_count = 2
  # }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  template {
    timeout = "180s"
    # service_account                  = ""
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 10

    scaling { # per-revision scaling
      min_instance_count = 2
      max_instance_count = 2
    }

    vpc_access {
      connector = google_vpc_access_connector.vpc_connector.id
      egress    = "ALL_TRAFFIC"
    }

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        name           = "http1"
        container_port = 8080
      }

      resources {
        cpu_idle          = false
        startup_cpu_boost = true
        limits = {
          cpu    = "2"
          memory = "8192Mi"
        }
      }

      startup_probe {
        initial_delay_seconds = 5   # time after which container starts
        period_seconds        = 240 # time between two probe checks
        timeout_seconds       = 180 # time after which container is declared "unready"
        failure_threshold     = 2   # no. of times to  retry probe after it is declared "unready"
        tcp_socket {
          port = 8080
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
  name     = google_cloud_run_v2_service.main.name
  location = google_cloud_run_v2_service.main.location
  member   = "allUsers"
  role     = "roles/run.invoker"
}
