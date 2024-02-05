# Homelab
This repository contains my homelab setup.  
It consists of a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) node, in which we create a k8s cluster with [TalosOS](talos.dev)

# Requirements
In order to execute everything in this playbook, you will need to install a couple of tools
- [Talosctl](https://www.talos.dev/v1.6/introduction/getting-started/#talosctl)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Terraform](https://developer.hashicorp.com/terraform/install)

# Installation
## 01_Proxmox
The first step will need to be done manually on a physical machine.  
Download the latest [Proxmox image](https://www.proxmox.com/en/downloads/category/iso-images-pve) and copy it to a USB. After this insert the USB in the machine and follow the setup process of Proxmox.  

### Terraform preparation
In order to easily rollout VMs with terraform, you will need to add the Talos ISO image to the Proxmox host.  

#### Terraform user account
After the Proxmox node has been made available, login to it's GUI to create the account used by Terraform.
1. Add a user called `terraform` in the Proxmox realm.
2. Create a role with the required VM and datastore privileges.
3. Under Permissions, add the role to the created user
4. Generate an API key called `terraform-01` for the user.
5. Make sure to store your API key somewhere safe. Terraform wil ask for it in the next step

#### Upload Talos OS ISO 
Get the ISO URL from [Talos](https://github.com/siderolabs/talos/releases)  
In the Proxmox GUI, go to local storage -> ISO Images and then with Download from URL add the Talos image to node.

### 01_infra: Run terraform
After this, you will be able to use Terraform to roll out the desired VMs.  
The setup uses API token authentication, you will be prompted for it but can also be set by `export TF_VAR_proxmox_api_key_secret='API_KEY'`
Go into the proxmox directory, generate and execute the plan  
```bash
$ cd 01_infra/proxmox
$ terraform init
$ terraform plan -out proxmox.tfplan
$ terraform apply proxmox.tfplan 
```

This will deploy 4 vm's on the host. More details regarding the deployment can be found [here](01_infra/README.md).

## 02_Talos
Once the nodes are up and running, we can start by setting up TalosOS to bootstrap the cluster.
After starting the master node, open the console to view the IP of the machine, this will be used to bootstrap.  
Installing and connection the talos cluster will be done in steps. The IP's of the machines can be found in the interactive consoles of the proxmox VM's
 ```bash
$ cd 02_cluster/talos
# This will ask for the control-plane IP
$ ./01_init-control
```

Now open both controlplane.yaml and worker.yaml and add the following to the yaml files:
```yaml
machine:
  kubelet:
    extraArgs:
      rotate-server-certificates: true
```

In the controlplane.yaml also add the following:
```yaml
cluster:
  extraManifests:
    - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
    - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
now continue with the init proces: 

```bash
# This will ask for all worker noder IPs, enter comma seperated
$ ./02_init-workers
# After all the nodes are "ready", run
$ ./03_bootstrap
```

This will store all important files in the talos/.out/ folder. Keep these secure, and back them up. You need these files if you ever need to update your cluster or configure the cluster. 

### Managing the cluster
Upgrading both Talos OS itself and the kubernetes version, take a look at [my documentation](02_cluster/README.md)

## 03_base_resources
To start with a basic cluster with enough possibilities to deploy your applications, they are deployed in bulk. It also uses 1Password to store all secrets need throughout the deployment. 
Below is a table of all secrets that it expects to be stored in 1password. All details, and how to setup the 1Password connection can be found [here](03_base_resources/README.md).

| 1Password item         | Type      | Content            |
|------------------------|-----------|--------------------|
| Azure tenant           | password  | Password           |
||||
| ArgoCD admin password  | login     | Username, Password |
| ArgoCD Azure Secret    | password  | Password, Note     |
||||
| Authentik admin login  | login     | Username, Password |
| Authentik Azure Secret | password  | Password, Note     |
| Authentik GeoIP        | login     | Username, Password |
| Authentik Secret Key   | password  | Password           |
| Authentik Token        | password  | Password           |
||||
| Cloudflare DNS token   | password  | Password           |
||||
| Database-PostgreSQL    | database  | Hostname, Port, Username, Password     |
| Database-Authentik     | database  | Username, Password |
| Database-Firefly       | database  | Username, Password |


Running the following commands will depliy all base resources mentioned here. During the terraform plan phase it will request you to enter the 1Password service token.

```bash
$ cd 03_base_resources
$ terraform init
$ terraform plan -out plan.tfplan
$ terraform apply plan.tfplan 
```
