resource "google_workbench_instance" "wb_instance" {
  for_each = var.workbench_instance_name
  name     = each.key
  location = "us-central1-a"

  gce_setup {
    machine_type = "e2-standard-4"

    boot_disk {
      disk_type    = "PD_STANDARD"
      disk_size_gb = 200
    }

    data_disks {
      disk_type    = "PD_STANDARD"
      disk_size_gb = 300
    }
  }
}