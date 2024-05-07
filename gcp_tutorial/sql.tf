resource "google_sql_database_instance" "my_first_sql_instance" {
  name                = "my-first-sql-instance"
  deletion_protection = false
  database_version    = "MYSQL_8_0"

  settings {
    edition = "ENTERPRISE"
    tier    = "db-f1-micro"
  }
}

resource "google_sql_user" "users" {
  name     = "shubham"
  password = "change@me"
  instance = google_sql_database_instance.my_first_sql_instance.name
}

