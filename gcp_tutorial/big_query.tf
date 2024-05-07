resource "google_bigquery_dataset" "my_first_ds" {
  dataset_id = "my_first_dataset"

}

resource "google_bigquery_table" "my_first_table" {
  table_id            = "my-first-table"
  dataset_id          = google_bigquery_dataset.my_first_ds.dataset_id
  deletion_protection = false
}