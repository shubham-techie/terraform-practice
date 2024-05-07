resource "google_bigtable_instance" "my_first_bigtable_instance" {
  name                = "my-first-bigtable-instance"
  deletion_protection = false

  cluster {
    cluster_id   = "my-first-bg-inst-id"
    num_nodes    = 1
    storage_type = "SSD"
  }
}

resource "google_bigtable_table" "my_first_bigtable_table" {
  name          = "my-first-bigtable-table"
  instance_name = google_bigtable_instance.my_first_bigtable_instance.name
}