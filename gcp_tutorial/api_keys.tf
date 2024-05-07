resource "google_apikeys_key" "my_demo_apikey" {
  name         = "my-temp-apikey"
  display_name = "My first apikey from terraform"

  restrictions {
    api_targets {
      service = "translate.googleapis.com"
      methods = ["GET*"]
    }

    browser_key_restrictions {
      allowed_referrers = [".*"]
    }
  }
}