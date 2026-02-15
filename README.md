# Cloud Provider VM Provisioning with Terraform

This project uses Terraform to provision Virtual Machines (VMs) on **DigitalOcean** or **Google Cloud Platform (GCP)**. The VMs are created using SSH keys stored in a local file.

**Supported providers:** DigitalOcean, GCP (select via `cloud_provider` variable)

## Prerequisites

- OpenTofu / Terraform installed
- Cloud provider credentials (see below)
- SSH keys

## Setup

1. Clone this repository.

2. Choose your cloud provider and configure credentials:

   **DigitalOcean** (set `cloud_provider = "digitalocean"` or omit, as it is the default):
   - **`.env` file** (simplest): Create a `.env` file with your token on a single line (no variable name, just the token). This file is gitignored.
   - **Environment variable**: `export TF_VAR_digitalocean_token="your-token"`
   - **terraform.tfvars** (gitignored): `digitalocean_token = "your-token"`

   **GCP** (set `cloud_provider = "gcp"`):
   - **Application Default Credentials**: Run `gcloud auth application-default login`
   - **Service account**: Set `GOOGLE_APPLICATION_CREDENTIALS` to the path of your service account JSON file, or use `gcp_credentials_file` in terraform.tfvars
   - Set `gcp_project_id` to your GCP project ID (required for GCP)

3. Create a file named `ssh_keys.txt` in the root directory of the project. Add your public SSH keys, one per line.

   ```text
   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
   ```

> [!TIP]
>
> - Guide to create an SSH key [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
> - To install [OpenTofu](https://opentofu.org/docs/intro/install/) or [Terraform](https://developer.hashicorp.com/terraform/install) follow these official documentation.

## Usage

To initialize the tools, run the following command(s):

OpenTofu:

```sh
tofu init
```

Terraform:

```sh
terraform init
```

To provision the VMs, run the following command(s):

OpenTofu:

```sh
tofu apply
```

Terraform:

```sh
terraform apply
```

This will read the SSH keys from `ssh_keys.txt`, create a corresponding VM for each key on your chosen provider, and output the IP address and the associated SSH key.

### Example: Using GCP

```hcl
# terraform.tfvars
cloud_provider = "gcp"
gcp_project_id = "my-gcp-project"
gcp_zone       = "us-central1-a"
```

Then run `gcloud auth application-default login` before `tofu apply`.

> [!TIP]
> - DigitalOcean regions: [Regional availability](https://docs.digitalocean.com/platform/regional-availability/)
> - GCP regions and zones: [Regions and zones](https://cloud.google.com/compute/docs/regions-zones)

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
