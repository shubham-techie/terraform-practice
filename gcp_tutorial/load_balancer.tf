locals {
   network = "projects/polar-surfer-419204/global/networks/default"
 }

# VPC network
resource "google_compute_network" "lb_network" {
  name                    = "lb-network"
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "lb_subnet" {
  name          = "lb-subnet"
  ip_cidr_range = "10.1.2.0/24"
  region        = var.region
  network       = google_compute_network.lb_network.id
}

# proxy-only subnet
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.129.0.0/23"
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.lb_network.id
}

# firewall for VM to allow ssh into internal VM, so that internal LB can be tested
resource "google_compute_firewall" "allow-ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.lb_network.id
  source_ranges = ["35.235.240.0/20"]
  #   target_tags = ["allow-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


# Reserved internal address
resource "google_compute_address" "lb_ip_adrress" {
  name         = "l7-ilb-ip"
  subnetwork   = google_compute_subnetwork.lb_subnet.id
  address_type = "INTERNAL"
  address      = "10.0.1.5"
  region       = var.region
  purpose      = "SHARED_LOADBALANCER_VIP"
}

##################### cert.tf
# Self signed cert to be replaced by us in console
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem
  # Certificate expires after 3 months.
  validity_period_hours = 2192

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["manual.com"]

  subject {
    common_name  = "manual.com"
    organization = "cdds"
  }
}

resource "google_compute_region_ssl_certificate" "default" {
  name_prefix = "self-cert-"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
  region      = var.region
  lifecycle {
    create_before_destroy = true
  }
}


# cloudrun
resource "google_cloud_run_v2_service" "default" {
  name     = "hello"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}

# cloudrun invoker role
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# serverless NEG
resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "cloudrun-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  #   network = var.network
  #   subnetwork = var.network

  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

# backend service for serverless NEG
resource "google_compute_region_backend_service" "regional_backend_service" {
  name                  = "regional-backend-service"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"
  #   network = var.network

  backend {
    group          = google_compute_region_network_endpoint_group.cloudrun_neg.id
    balancing_mode = "UTILIZATION"
  }
}

# actual LB is provisoned here without network
resource "google_compute_region_url_map" "regional_url_map" {
  name            = "regional-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.regional_backend_service.id
}

# resource "google_compute_region_target_http_proxy" "regional_http_proxy" {
#   name    = "regional-http-proxy"
#   region  = var.region
#   url_map = google_compute_region_url_map.regional_url_map.id
# }

resource "google_compute_region_target_https_proxy" "regional_https_proxy" {
  name             = "regional-https-proxy"
  region           = var.region
  url_map          = google_compute_region_url_map.regional_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.default.self_link]
}

# LB frontend and basic configuration is set with network
resource "google_compute_forwarding_rule" "forwarding_rule" {
  name       = "forwarding-rule"
  region     = var.region
  network    = google_compute_network.lb_network.id
  subnetwork = google_compute_subnetwork.lb_subnet.id
  #   network          = var.network
  #   subnetwork       = var.subnetwork

  depends_on = [google_compute_subnetwork.proxy_only_subnet]
    ip_address       = google_compute_address.lb_ip_adrress.id
  #   source_ip_ranges = ""

  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  
  # port_range            = "80"
  # target                = google_compute_region_target_http_proxy.regional_http_proxy.id

  port_range            = "443"
  target                = google_compute_region_target_https_proxy.regional_https_proxy.id
  network_tier          = "PREMIUM"
}


resource "google_dns_managed_zone" "private_zone" {
  name       = "private-zone"
  dns_name   = "manual.com."
  visibility = "private"
  #   force_destroy = true

  private_visibility_config {
    networks {
      network_url = google_compute_network.lb_network.id
    }
  }
}

resource "google_dns_record_set" "lb_host" {
  name         = google_dns_managed_zone.private_zone.dns_name
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_forwarding_rule.forwarding_rule.ip_address]
}

# LB ip-address
output "load_balancer_ip" {
  value = google_compute_forwarding_rule.forwarding_rule.ip_address
}

