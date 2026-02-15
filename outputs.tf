locals {
  vm_info_output = var.cloud_provider == "digitalocean" ? [
    for i in range(length(digitalocean_droplet.web)) : {
      name       = digitalocean_droplet.web[i].name
      id         = digitalocean_droplet.web[i].id
      ip_address = digitalocean_droplet.web[i].ipv4_address
      ssh_key    = local.ssh_keys[i]
    }
    ] : [
    for i in range(length(google_compute_instance.vm)) : {
      name       = google_compute_instance.vm[i].name
      id         = google_compute_instance.vm[i].instance_id
      ip_address = google_compute_instance.vm[i].network_interface[0].access_config[0].nat_ip
      ssh_key    = local.ssh_keys[i]
    }
  ]
}

output "vm_info" {
  description = "List of created VMs with IP address, name, ID, and associated SSH key"
  value       = local.vm_info_output
}

output "droplet_info" {
  description = "Alias for vm_info (deprecated, use vm_info instead)"
  value       = local.vm_info_output
}
