output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = google_compute_address.static_ip.address
}

output "instance_name" {
  description = "Name of the created instance"
  value       = google_compute_instance.student_app_vm.name
}

output "zone" {
  description = "Zone where the instance is deployed"
  value       = google_compute_instance.student_app_vm.zone
}

output "gcloud_ssh_command" {
  description = "gcloud command to SSH into the VM"
  value       = "gcloud compute ssh ${google_compute_instance.student_app_vm.name} --zone ${google_compute_instance.student_app_vm.zone} --project ${var.gcp_project}"
}