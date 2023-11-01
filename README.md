# Homelab
This repository contains my homelab setup.  
It consists of a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) node, in which we create a k8s cluster with [TalosOS](talos.dev)

# Requirements
In order to execute everything in this playbook, you will need to install a couple of tools
- [talosctl](https://www.talos.dev/v1.1/introduction/getting-started/#talosctl)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [kustomize](https://github.com/kubernetes-sigs/kustomize)

# Installation
## Proxmox
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

#### ISO 
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

## Talos
Once the nodes are up and running, we can start by setting up TalosOS to bootstrap the cluster.
After starting the master node, open the console to view the IP of the machine, this will be used to bootstrap.  
Installing and connection the talos cluster will be done in steps. The IP's of the machines can be found in the interactive consoles of the proxmox VM's
 ```bash
$ cd 02_cluster/talos
# This will ask for the control-plane IP
$ ./01_init-control
# This will ask for all worker noder IPs, enter comma seperated
$ ./02_init-workers
# After all the nodes are "ready", run
$ ./03_bootstrap
```

This will store all important files in the talos/.out/ folder. Keep these secure.

## Initial deployments
For proper usage of the cluster, a couple of deployments will need to be created.  
The initial deployment in this case is an ArgoCD instance for managing deployments and MetalLB for providing a LoadBalancer for the cluster.  
I use a separate repository for my k8s deployments, so I can easily utilize kustomize, [check it out](https://github.com/rcomanne/k8s-infra-deployments)!  

### ArgoCD
Argo is deployed using Terraform. Follow the script that will deploy argoCD.   
```bash
$ cd 04_argocd
$ terraform init
$ terraform plan -out argocd.tfplan
$ terraform apply argocd.tfplan 
```

If you receive the following error: 

```error
Kubernetes cluster unreachable: invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable
```

After ArgoCD is up and running, you are able to reach it by port-forwarding the deployment and after that exporting the secret, created by the deployment.
```bash
$ kubectl port-forward svc/argocd-server 8080:80
$ echo "Login with admin:$(kubectl get secrets -n argo -o json argocd-initial-admin-secret | jq -r '.data.password' | base64 -d)"
```

Run: 
```bash
$ export KUBE_CONFIG_PATH=/path/to/.kube/config
```

### MetalLB
MetalLB is a little more tricky in it's workings, as it heavily relies on your network structure.  
A simple script has been added that works on my network, but you will probably have to change the IP range in the `addresspool.yaml` file.  
For more information, check out the [MetalLB configuration documentation](https://metallb.org/configuration/).