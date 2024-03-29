variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to the private key used to connect to instance"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable server_count {
  default = 1
}

variable db_internal_ip {
  description = "Database network IP"
}

variable environment {
  description = "Environment type: stage or prod"
}
