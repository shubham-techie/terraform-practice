# create pub-sub topic
# create pub-sub subscription
# scheduler job

resource "google_pubsub_topic" "scheduled_topic" {
  name = "my-first-scheduled-topic"
}

resource "google_pubsub_subscription" "scheduled_subscription" {
  name  = "my-first-pubsub-subscription"
  topic = google_pubsub_topic.scheduled_topic.name
}

resource "google_cloud_scheduler_job" "scheduler" {
  name     = "my-first-scheduler"
  schedule = "*/2 * * * *"

  pubsub_target {
    topic_name = google_pubsub_topic.scheduled_topic.id
    data       = base64encode("Hey, message dropped from terraform.")
  }
}