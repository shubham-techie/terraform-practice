resource "google_compute_disk" "main" {
  name = "disk-1"
  size = 100
  type = "pd-ssd"
  zone = var.zone
}

resource "google_compute_attached_disk" "vm_data_disk" {
  disk     = google_compute_disk.main.id
  instance = google_compute_instance.main.id
}