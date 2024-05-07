resource "google_redis_instance" "my_first_redis_instance" {
  name               = "my-first-redis-instance"
  display_name       = "My first redis instance with terraform"
  memory_size_gb     = 50
  tier               = "BASIC"
  location_id        = "us-central1-a"
  authorized_network = "default"
  redis_version      = "REDIS_5_0"
}