resource "google_spanner_instance" "main" {
  name         = "my-first-spanner-instance"
  display_name = "My first Spanner Instance"
  config       = "regional-${var.region}"
  num_nodes    = 1
}

resource "google_spanner_database" "my_first_spanner_db" {
  name                = "my-first-spanner-db"
  instance            = google_spanner_instance.main.name
  deletion_protection = false
}