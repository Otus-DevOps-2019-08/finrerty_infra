resource "google_compute_instance" "app" {
  name         = "reddit-app-${var.environment}-${count.index}"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["puma-server"]
  count        = var.server_count

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = var.app_disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }

  metadata = {
    # путь до публичного ключа
    ssh-keys               = "vlad:${file(var.public_key_path)}"
    block-project-ssh-keys = false
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "vlad"
    agent       = false
    private_key = file(var.private_key_path)
  }

#  provisioner "file" {
#    source      = "../modules/app/files/puma.service"
#    destination = "/tmp/puma.service"
#  }

#  provisioner "remote-exec" {
#    inline = ["echo export DATABASE_URL=\"${var.db_internal_ip}\" >> ~/.profile"]
#  }

#  provisioner "remote-exec" {
#    script = "../modules/app/files/deploy.sh"
#  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "default-puma-server"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["80", "9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["puma-server"]
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}
