resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = local.network
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = local.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# PostgreSQL instance with private IP
# set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by use of Terraform whereas
# `deletion_protection_enabled` flag protects this instance at the GCP level.
resource "google_sql_database_instance" "postgres_db_instance" {
  name             = "main-instance1"
  database_version = "POSTGRES_15"
  region           = "us-central1"
  deletion_protection = false
  
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    availability_type= "REGIONAL"
    tier = "db-perf-optimized-N-8"
    edition = "ENTERPRISE_PLUS"
    deletion_protection_enabled = false
    disk_type = "PD_SSD"
    disk_size = 500

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = local.network
      enable_private_path_for_google_cloud_services = true
      require_ssl = false
      ssl_mode = "ENCRYPTED_ONLY"
    }

    backup_configuration {
        enabled = true
    #    point_in_time_recovery_enabled = true
    }
  }
}

resource "random_string" "root_password" {
  length           = 16
  override_special = "%*()-_=+[]{}?"
}

resource "google_sql_user" "built_in_user" {
  name     = "root"
  instance = google_sql_database_instance.postgres_db_instance.name
  # password = random_string.root_password.result
  password = "changeme"
  type = "BUILT_IN"
}

resource "google_sql_user" "iam_user" {
  name     = "test-user@example.com"
  instance = google_sql_database_instance.postgres_db_instance.name
  type     = "CLOUD_IAM_USER"
}


resource "google_service_account" "sql_sa" {
  account_id   = "cloud-sql-postgres-sa"
  display_name = "Cloud SQL for Postgres Service Account"
}

# for PostgreSQL only, Google Cloud requires that you omit the ".gserviceaccount.com" suffix from the service account email due to length limits on database usernames.
resource "google_sql_user" "iam_service_account_user" {
  name     = trimsuffix(google_service_account.sql_sa.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.postgres_db_instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}