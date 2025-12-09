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