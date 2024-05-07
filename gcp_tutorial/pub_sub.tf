resource "google_pubsub_topic" "my_first_topic" {
  name = "my-first-topic"
}

resource "google_pubsub_subscription" "my_first_sub" {
  name  = "my-first-sub"
  topic = google_pubsub_topic.my_first_topic.name
}