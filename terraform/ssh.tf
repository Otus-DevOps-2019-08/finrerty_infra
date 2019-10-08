resource "google_compute_project_metadata" "ssh-keys" {
  metadata = {
    ssh-keys = <<EOF
    vlad:${file(var.public_key_path)}
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
    appuser3:${file(var.public_key_path)}
EOF
  }
}

