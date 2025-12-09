# main.tf - Complete Terraform configuration
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "student-app-vm"
}

variable "vm_type" {
  description = "Machine type for the VM"
  type        = string
  default     = "e2-medium"
}

variable "vm_image" {
  description = "OS image for the VM"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

resource "google_compute_address" "static_ip" {
  name    = "${var.vm_name}-ip"
  region  = var.gcp_region
  project = var.gcp_project
}

resource "google_compute_firewall" "allow_app_ports" {
  name    = "allow-student-app-ports"
  network = "default"
  project = var.gcp_project

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000", "3001", "7373", "9393", "30001", "31349"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["student-app"]
}

resource "google_compute_instance" "student_app_vm" {
  name         = var.vm_name
  machine_type = var.vm_type
  zone         = var.gcp_zone
  project      = var.gcp_project

  tags = ["student-app", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.disk_size
      type  = "pd-standard"
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

  metadata_startup_script = <<-EOF
    #!/bin/bash
    
    echo "=== VM Startup Script ==="
    echo "VM Hostname: $(hostname)"
    echo "Public IP: $(curl -s ifconfig.me)"
    
    sudo apt-get update -y
    sudo apt-get upgrade -y
    
    sudo apt-get install -y \
      curl \
      wget \
      git \
      vim \
      net-tools \
      htop \
      tree \
      jq
    
    echo "Installing Docker..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    echo "Installing Kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    
    sudo mkdir -p /opt/student-app
    sudo chown -R ubuntu:ubuntu /opt/student-app
    
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    
    echo "fs.file-max = 1000000" | sudo tee -a /etc/sysctl.conf
    echo "ubuntu soft nofile 1000000" | sudo tee -a /etc/security/limits.conf
    echo "ubuntu hard nofile 1000000" | sudo tee -a /etc/security/limits.conf
    
    sudo mkdir -p /etc/docker
    cat << DOCKER_EOF | sudo tee /etc/docker/daemon.json
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "100m"
      },
      "storage-driver": "overlay2"
    }
    DOCKER_EOF
    
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    cat << KIND_EOF > /opt/student-app/kind-config.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      extraPortMappings:
      - containerPort: 30001
        hostPort: 30001
        listenAddress: "0.0.0.0"
        protocol: TCP
      - containerPort: 31349
        hostPort: 31349
        listenAddress: "0.0.0.0"
        protocol: TCP
      - containerPort: 7373
        hostPort: 7373
        listenAddress: "0.0.0.0"
        protocol: TCP
      - containerPort: 9393
        hostPort: 9393
        listenAddress: "0.0.0.0"
        protocol: TCP
    KIND_EOF
    
    sudo apt-get autoremove -y
    sudo apt-get clean
    
    sudo chown -R ubuntu:ubuntu /opt/student-app
    
    echo "=== Startup Script Complete ==="
    echo "Docker version: $(docker --version)"
    echo "Docker Compose version: $(docker-compose --version)"
    echo "kubectl version: $(kubectl version --client --short)"
    echo "Kind version: $(kind version)"
  EOF

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = google_compute_address.static_ip.address
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.student_app_vm.network_interface[0].network_ip
}

output "instance_id" {
  description = "Instance ID"
  value       = google_compute_instance.student_app_vm.instance_id
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${google_compute_address.static_ip.address}"
}

output "app_urls" {
  description = "Application URLs"
  value = {
    backend_health = "http://${google_compute_address.static_ip.address}:30001/api/health"
    frontend       = "http://${google_compute_address.static_ip.address}:31349"
    custom_port    = "http://${google_compute_address.static_ip.address}:7373"
  }
}