resource "google_project_service" "services" {
  for_each                   = var.gcp_service_list
  service                    = each.key
  disable_dependent_services = true

  # lifecycle {
  #   prevent_destroy = true
  # }
}
