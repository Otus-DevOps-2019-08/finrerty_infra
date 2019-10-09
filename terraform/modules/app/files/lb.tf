resource "google_compute_http_health_check" "lb-reddit-check" {
  name = "lb-reddit-check"
  port = "9292"
}

resource "google_compute_target_pool" "lb-reddit-app" {
  name      = "lb-reddit-app"
  instances = "${google_compute_instance.app.*.self_link}"

  health_checks = ["${google_compute_http_health_check.lb-reddit-check.name}"]
}

resource "google_compute_forwarding_rule" "lb-reddit-forwarding" {
  name       = "lb-reddit-forwarding"
  target     = "${google_compute_target_pool.lb-reddit-app.self_link}"
  port_range = "9292"
}
