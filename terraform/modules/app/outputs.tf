output "app_external_ip" {
  value = google_compute_instance.app.0.network_interface.0.access_config.0.nat_ip
}

output "app2_external_ip" {
  value = google_compute_instance.app.1.network_interface.0.access_config.0.assigned_nat_ip
}

# output "lb_ip" {
#   value = "${google_compute_forwarding_rule.lb-reddit-forwarding.ip_address}"
# }

