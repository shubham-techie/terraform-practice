resource "google_compute_instance" "main" {
  name         = "instance-tf"
  machine_type = "n2-standard-2"
  # zone                      = "${google_compute_subnetwork.auto_vpc_subnet.region}-a"
  zone                      = var.zone
  allow_stopping_for_update = true # IMP

  network_interface {
    network    = google_compute_network.custom_vpc.name
    subnetwork = "subnet-1"

    access_config { # IMP : empty block is only responsible of assigning external ip
    }
  }

  boot_disk {
    auto_delete = false

    initialize_params {
      image = "debian-11-bullseye-arm64-v20240415"
      size  = 100
    }
  }

  labels = {
    "env"        = "dev"
    "department" = "devops"
  }

  scheduling {
    # provisioning_model = "SPOT"
    # preemptible        = true
    # automatic_restart  = false

    provisioning_model = "STANDARD"
    preemptible        = false
    automatic_restart  = true
  }

  service_account {
    email = "763272322972-compute@developer.gserviceaccount.com" # NOTE : existing email can directly be referenced as string
    scopes = [
      "cloud-platform"
    ]
  }

  lifecycle {
    # create_before_destroy = true

    ignore_changes = [
      attached_disk
    ]
  }
}