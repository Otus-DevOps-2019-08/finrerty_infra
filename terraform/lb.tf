resource "google_compute_http_health_check" "lb-reddit-check" {
  name = "lb-reddit-check"
  port = "9292"
}

resource "google_compute_target_pool" "lb-reddit-app" {
  name = "lb-reddit-app"
  instances = [
    "europe-west1-b/reddit-app",
    "europe-west1-b/reddit-app-2",
  ]

  health_checks = ["${google_compute_http_health_check.lb-reddit-check.name}"]
}

resource "google_compute_forwarding_rule" "lb-reddit-forwarding" {
  name = "lb-reddit-forwarding"
  target = "${google_compute_target_pool.lb-reddit-app.self_link}"
  port_range = "9292"
}
