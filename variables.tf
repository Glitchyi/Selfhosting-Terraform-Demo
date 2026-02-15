variable "cloud_provider" {
  description = "Cloud provider to use: digitalocean or gcp"
  type        = string
  default     = "digitalocean"

  validation {
    condition     = contains(["digitalocean", "gcp"], var.cloud_provider)
    error_message = "cloud_provider must be either 'digitalocean' or 'gcp'."
  }
}

variable "digitalocean_token" {
  description = "DigitalOcean API token. If not set, reads from .env file. Used when cloud_provider is digitalocean."
  type        = string
  sensitive   = true
  default     = ""
}

variable "region" {
  description = "DigitalOcean region for droplets (used when cloud_provider is digitalocean)"
  type        = string
  default     = "blr1"
}

variable "droplet_size" {
  description = "DigitalOcean droplet size slug (used when cloud_provider is digitalocean)"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_image" {
  description = "DigitalOcean droplet image slug (used when cloud_provider is digitalocean)"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "gcp_project_id" {
  description = "GCP project ID. Required when cloud_provider is gcp."
  type        = string
  default     = ""
}

variable "gcp_zone" {
  description = "GCP zone for compute instances. Used when gcp_zones is not set."
  type        = string
  default     = "us-central1-a"
}

variable "gcp_zones" {
  description = "List of GCP zones to spread VMs across. If set, VMs are distributed round-robin across zones (helps when one zone has no capacity)."
  type        = list(string)
  default     = []
}

variable "gcp_machine_type" {
  description = "GCP machine type (used when cloud_provider is gcp). e2-micro is free tier eligible."
  type        = string
  default     = "e2-micro"
}

variable "gcp_image" {
  description = "GCP image family for compute instances (used when cloud_provider is gcp)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "gcp_credentials_file" {
  description = "Path to GCP service account JSON file. If empty, uses Application Default Credentials."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_key_file" {
  description = "Path to file containing SSH public keys (one per line)"
  type        = string
  default     = "ssh_keys.txt"
}

variable "project_tags" {
  description = "Tags to apply to all droplets/VMs"
  type        = list(string)
  default     = ["terraform", "selfhosting"]
}
