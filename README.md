# DigitalOcean VM Provisioning with Terraform

This project uses Terraform to provision Virtual Machines (VMs) on DigitalOcean. The VMs are created using SSH keys stored in a local file.

## Prerequisites

- OpenTofu / Terraform installed
- DigitalOcean API Token
- SSH keys

## Setup

1. Clone this repository.
2. Create a `.env` file in the root directory of the project and simply add your DigitalOcean API token:

    ```text
    <Your DigitalOcean API Token>
    ```

3. Add your SSH keys to a file named `ssh_keys.txt` in the root directory of the project. Each SSH key should be on a new line.

Guide to create an SSH key [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## Usage

To provision the VMs, run the following command(s):

OpenTofu:

```sh
tofu apply
```

Terraform:

```sh
terraform apply
```

This will read the SSH keys from the `ssh_keys.txt` file and create a VM for each key in the `nyc3` region on DigitalOcean.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
