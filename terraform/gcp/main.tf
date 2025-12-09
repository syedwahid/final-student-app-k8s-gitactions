# main.tf - Simple GCP VM Setup
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

variable "vm_name" {
  type    = string
  default = "student-app-vm"
}

variable "vm_type" {
  type    = string
  default = "e2-medium"
}

variable "vm_image" {
  type    = string
  default = "ubuntu-2204-lts"
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "ssh_public_key" {
  type = string
}

# Static IP
resource "google_compute_address" "static_ip" {
  name   = "${var.vm_name}-ip"
  region = var.gcp_region
}

# Firewall
resource "google_compute_firewall" "allow_ports" {
  name    = "allow-student-app"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000", "3001", "7373", "9393", "30001", "31349"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# VM Instance
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_type
  zone         = var.gcp_zone

  tags = ["student-app"]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  # Simple startup script
  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "VM is ready!"
    sudo apt-get update -y
    sudo apt-get install -y docker.io curl
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    echo "Setup complete"
  EOF
}

output "vm_public_ip" {
  value = google_compute_address.static_ip.address
}