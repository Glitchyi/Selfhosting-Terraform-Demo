terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.34.1"
    }
  }
}


provider "digitalocean" {
  token = file(".env")
}

data "local_file" "ssh_keys" {
  filename = "ssh_keys.txt" 
}

locals {
  ssh_keys = split("\n", data.local_file.ssh_keys.content)
}

resource "digitalocean_droplet" "web" {
  count              = length(local.ssh_keys)
  name               = "vm-${count.index + 1}"
  region             = "blr1"  # Replace with your desired region
  size               = "s-1vcpu-1gb"
  image              = "ubuntu-20-04-x64"
  ssh_keys           = [digitalocean_ssh_key.ssh_key[count.index].fingerprint]
}

# Create DigitalOcean SSH keys from the keys read from the file
resource "digitalocean_ssh_key" "ssh_key" {
  count       = length(local.ssh_keys)
  name        = "ssh-key-${count.index + 1}"
  public_key  = local.ssh_keys[count.index]
}

output "droplet_info" {
  value = join("\n", [
    for droplet in digitalocean_droplet.web :
    "${droplet.name} : ${droplet.ipv4_address}"
  ]
  )
}

