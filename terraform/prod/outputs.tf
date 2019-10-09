output "app_external_ip" {
  value = module.app.app_external_ip
}

output "app2_external_ip" {
  value = module.app.app2_external_ip
}

# output "lb_ip" {
#   value = "${google_compute_forwarding_rule.lb-reddit-forwarding.ip_address}"
# }
