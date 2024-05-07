terraform {
  backend "gcs" {
    bucket      = "tf-state-dev-6501" # IMP : Bucket need to pre-exist
    prefix      = "terraform/state"
    credentials = "service_act_key.json"
  }
}