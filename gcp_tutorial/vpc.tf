resource "google_compute_network" "auto_vpc" {
  name = "auto-vpc"
}

resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "auto_vpc_subnet" {
  name                     = "subnet-1"
  network                  = google_compute_network.custom_vpc.id
  ip_cidr_range            = "10.1.0.0/24"
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "alllow-icmp"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
  source_ranges = [
    "152.57.5.210/32"
  ]
  priority = 10
}