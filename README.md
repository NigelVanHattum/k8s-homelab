# Homelab
This repository contains my homelab setup.  
It consists of a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) node, in which we create a k8s cluster with [TalosOS](talos.dev)

# Requirements
In order to execute everything in this playbook, you will need to install a couple of tools
- [talosctl](https://www.talos.dev/v1.1/introduction/getting-started/#talosctl)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [kustomize](https://github.com/kubernetes-sigs/kustomize)

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

This will store all important files in the talos/.out/ folder. Keep these secure.

## 03_ArgoCD
Argo is deployed using Terraform. Follow the script that will deploy argoCD.   
```bash
$ cd 03_argocd
$ terraform init
$ terraform plan -out argocd.tfplan
$ terraform apply argocd.tfplan 
```

If you receive the following error: 

```error
Kubernetes cluster unreachable: invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable
```
Run: 
```bash
$ export KUBE_CONFIG_PATH=/path/to/.kube/config
```

After ArgoCD is up and running, you are able to reach it by port-forwarding the deployment and after that exporting the secret, created by the deployment.
```bash
$ kubectl port-forward svc/argocd-server 8080:80
$ echo "Login with admin:$(kubectl get secrets -n argo -o json argocd-initial-admin-secret | jq -r '.data.password' | base64 -d)"
```

## 04_Storage
In order to have a seperate storage provider, I am using a NFS provider. Deployment of this chart is done through ArgoCD. 

```bash
$ cd 04_storage
$ terraform init
$ terraform plan -out storage.tfplan
$ terraform apply storage.tfplan 
```

## 05_Networking
Below is some information about everything that is deploy with the following script:
```bash
$ cd 05_networking
$ terraform init
$ terraform plan -out networking.tfplan
$ terraform apply networking.tfplan 
```

### MetalLB
MetalLB provides a loadbalancer on the cluster, that will allow external access to the cluster. 
The files located in the manifests folder are defining 2 ip ranges that will be advertised by the advertisement.yaml. 

- traefik-addresspool: The IP address that will be used to expose traefik
- extra-addresspool: Some extra IP space if needed


### Traefik
Traefik will be deployed as the reverse proxy for all services. This will have an added entrypoint compared to the default deployment. The entrypoints are as follows:
| Name          | Enabled   | Port      | Usage                     |
|---------------|-----------|-----------|---------------------------|
| traefik       | False     | 9000      | No clue                   |
| metrics       | False     | 9100      | Metrics...                |
| web           | True      | 8000      | Should it still be here?  |
| websecure     | True      | 443       | local network             |
| internet      | True      | 6443      | public internet           |

## 06_database

### PostgreSQL
PostgreSQL is deployed via the Bitname postgresql-ha helm chart using ArgoCD. You will be asked to create a password for the postgres user. 

If you ever forget the password, here is how to retrieve it:

```Bash
kubectl get secret "postgres-admin-password" -o json -n postgresql | jq -r ".[\"data\"][\"password\"]" | base64 -d 
```

### 06_database_06_01_management
The database is not exposed outside the cluster, to connect to the database you first need to port-forward the database port: 
```Bash
kubectl port-forward service/postgresql-postgresql-ha-postgresql 5432:5432 -n postgresql
```