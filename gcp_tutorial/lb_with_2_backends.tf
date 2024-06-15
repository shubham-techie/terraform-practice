# neg for frontend cloudrun
resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = "keypro-ui-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.service.name
  }
}


# lb backend service for frontend cloudrun
resource "google_compute_region_backend_service" "bes" {
  name                  = "keypro-ui-bservice"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.neg.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


# neg for backend cloudrun
resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "${var.backend_app_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.cr_backend.name
  }
}


# lb backend service for backend cloudrun
resource "google_compute_region_backend_service" "keypro_backend_service" {
  name                  = "${var.backend_app_name}-bservice"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.backend_neg.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

 
# lb url-map
resource "google_compute_region_url_map" "url_map" {
  name            = "keypro-ui-lb"
  project         = var.project_id
  region          = var.region
  default_service = google_compute_region_backend_service.bes.id

  host_rule {
    hosts        = [trimsuffix(var.ilb_domain, ".")]
    path_matcher = "path-matcher-1"
  }

  path_matcher {
    default_service = google_compute_region_backend_service.bes.id
    name            = "path-matcher-1"

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_region_backend_service.keypro_backend_service.id
    }
  }
}


#resource "google_compute_region_target_https_proxy" "proxy" {
  #name             = "ilb-https-proxy"
  #url_map          = google_compute_region_url_map.url_map.id
  #region           = var.region
  #ssl_certificates = [google_compute_region_ssl_certificate.default.self_link]

  # ignore cert changes to allow for updating with the real cert
  #lifecycle {
  #  ignore_changes = [
  #    ssl_certificates
  #  ]
  #}
#}

resource "google_compute_region_target_http_proxy" "proxy" {
  name             = "${var.project_id}-ilb-http-proxy"
  url_map          = google_compute_region_url_map.url_map.id
  region           = var.region
}

resource "google_compute_forwarding_rule" "rules" {
  name                  = "keypro-ui"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  # port_range            = "443"
  # target                = google_compute_region_target_https_proxy.proxy.id
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.proxy.id
  network               = var.network
  subnetwork            = var.subnet_link
  # ip_address           = var.ilb_static_ip
}




