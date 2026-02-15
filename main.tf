locals {
  # Use variable if set, otherwise fall back to .env file. Use dummy when GCP to avoid provider init failure.
  digitalocean_token = var.cloud_provider == "digitalocean" ? (var.digitalocean_token != "" ? var.digitalocean_token : try(trimspace(file(".env")), "")) : "dummy-unused-when-gcp"
  # Read the file content and split by newline, filtering out empty lines
  ssh_keys_raw     = split("\n", fileexists(var.ssh_key_file) ? file(var.ssh_key_file) : "")
  ssh_keys         = [for key in local.ssh_keys_raw : trimspace(key) if trimspace(key) != ""]
  use_digitalocean = var.cloud_provider == "digitalocean"
  use_gcp          = var.cloud_provider == "gcp"
  # Zones to use for GCP: gcp_zones if set, otherwise single gcp_zone
  gcp_zones        = length(var.gcp_zones) > 0 ? var.gcp_zones : [var.gcp_zone]
}

provider "digitalocean" {
  token = local.digitalocean_token
}

provider "google" {
  project     = var.gcp_project_id
  credentials = var.gcp_credentials_file != "" ? file(var.gcp_credentials_file) : null
}

# --- DigitalOcean resources ---

resource "digitalocean_ssh_key" "ssh_key" {
  count      = local.use_digitalocean ? length(local.ssh_keys) : 0
  name       = "ssh-key-${count.index + 1}"
  public_key = local.ssh_keys[count.index]
}

resource "digitalocean_droplet" "web" {
  count    = local.use_digitalocean ? length(local.ssh_keys) : 0
  name     = "vm-${count.index + 1}"
  region   = var.region
  size     = var.droplet_size
  image    = var.droplet_image
  ssh_keys = [digitalocean_ssh_key.ssh_key[count.index].fingerprint]
  tags     = var.project_tags
}

resource "digitalocean_firewall" "droplet_firewall" {
  count = local.use_digitalocean && length(local.ssh_keys) > 0 ? 1 : 0

  name = "droplet-firewall"

  droplet_ids = digitalocean_droplet.web[*].id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# --- GCP resources ---

resource "google_compute_firewall" "ssh" {
  count = local.use_gcp && length(local.ssh_keys) > 0 ? 1 : 0

  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.project_tags
}

resource "google_compute_instance" "vm" {
  count = local.use_gcp ? length(local.ssh_keys) : 0

  name         = "vm-${count.index + 1}"
  machine_type = var.gcp_machine_type
  zone         = local.gcp_zones[count.index % length(local.gcp_zones)]

  tags = var.project_tags

  boot_disk {
    initialize_params {
      image = var.gcp_image
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral external IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_keys[count.index]}"
  }
}
