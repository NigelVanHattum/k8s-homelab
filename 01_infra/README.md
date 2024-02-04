# Deploying your Talos OS vm's on Proxmox via Terraform

## Terraform cloud setup
Setting up your terraform cloud connection can be done following [this guide](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up).

After setting up your Terraform Cloud project & API key you will also have to ensure that your terraform runs are ran locally and not on their runners. To enable this follw these steps:
- From your Terraform workspaces overview, go to settings
- Choose the "Default Execution Mode" "local".

Now if your run any terraform commands with a cloud connection this workspace, your run will be done locally on your machine by default. 

## My VM setup
With my setup I just have a single machine which runs my vm's, but to enable multiple node setups for my k8s cluster I will create 4 vm's on this single machine

### Controlplane VM
The first vm I will deploy will later be used as the controleplane node for my k8s cluster. This is the "proxmox_vm_qemu.talos-controlpane" resource in the main.tf file. I hardcoded the MAC address that this VM will send out, this will help my router setup a static IP for this machine. 

### Worker VM's
I will not allow any deployment to directly run on the control plane node of my k8s cluster. To allow k8s to scale over worker nodes I will deploy 3 more vm's to split the workloads. these are the "proxmox_vm_qemu.k8s-workers" resource in the main.tf file. I hardcoded the MAC address that this VM will send out, this will help my router setup a static IP for this machine. 