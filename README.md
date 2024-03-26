# Homelab
This repository contains my homelab setup.  
It consists of a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) node, in which we create a k8s cluster with [TalosOS](talos.dev)

# Requirements
In order to execute everything in this playbook, you will need to install a couple of tools
- [Talosctl](https://www.talos.dev/v1.6/introduction/getting-started/#talosctl)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [1Password Account & CLI](https://developer.1password.com/docs/cli/)

# Installation setup

## 1Password
My setup heavily relies on 1Password as the secret storage for all credentials. The installation steps can be found in the requirements mentioned above. I am using the service account setup, with a vaultname "Homelab". This is the only secret that Terraform will request from your at every command you run. 
You can store the API key in your `terraform.tfvars`, but note. This is not a secure way :) 

Your terraform.tfvars file:
```
onepassword_service_token="YOUR_ONEPASSWORD_API_KEY"
```

## Terraform Cloud
Every subfolder in this repository has a `_cloud.tf` file. This is usaged to configure the connection to the terraform cloud. This is the place where I store my Terraform states. This way I am able to run commands from every machine, but will always share the same state. 

You can create a tf cloud account [here](https://app.terraform.io/session). Follow [this guide](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started) to get started using tf cloud. 

> [!WARNING]  
> Make sure to set the 'Default Execution Mode' to 'local'. Otherwise Terraform will try run your command on their cloud infrastructure. 

## Proxmox
The first step will need to be done manually on a physical machine.  
Download the latest [Proxmox image](https://www.proxmox.com/en/downloads/category/iso-images-pve) and copy it to a USB. After this insert the USB in the machine and follow the setup process of Proxmox.  

#### Terraform user account
After the Proxmox node has been made available, login to it's GUI to create the account used by Terraform.
1. Add a user called `terraform` in the Proxmox realm.
2. Create a role with the required VM and datastore privileges.
   - Permissions can be found in the terraform [provider docs](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs).
3. Under Permissions, add the role to the created user
4. Generate an API key called `terraform-01` for the user.
5. Store your API key in 1Password

#### Upload Talos OS ISO 
Get the ISO URL from [Talos](https://github.com/siderolabs/talos/releases)  
In the Proxmox GUI, go to local storage -> ISO Images and then with Download from URL add the Talos image to node.


## 01_infra
Follow the steps and guides listed [here](01_infra/README.md)

