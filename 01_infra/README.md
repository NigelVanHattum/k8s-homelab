# Deploying your Talos OS vm's on Proxmox via Terraform
Running the terraform files within this folder does the following:
- Deploy the vm's on proxmox, using the API key you have stored in 1Password
- Bootstrap a Talos k8s cluster on these VM's

## 1Password requirements
You will need the following items to be present in your 1Password vault:
<table>
    <thead>
        <tr>
            <th>1Password item name</th>
            <th>type</th>
            <th>field name</th>
            <th>remark</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=4>{{local.one_password_proxmox}}</td>
            <td rowspan=4>login</td>
        </tr>
        <tr>
            <td>url</td>
            <td>Should look something like {{proxmoxhost}}:8006/api2/json</td>
        </tr>
        <tr>
            <td>username</td>
            <td>Your Proxmox token name</td>
        </tr>
        <tr>
            <td>password</td>
            <td>Token value</td>
        </tr>
    </tbody>
</table>


## My VM setup (with example config)
With my setup I just have a single machine which runs my vm's, but to enable multiple node setups for my k8s cluster I will create 3 vm's on this single machine. This setup will be able to handle more machines and more vm's if you have the hardware for it. The easiest way to specify your vm's are to add the variables to your `terraform.tfvars` file. As mentioned I deploy 3 vm's, 1 to host the control node of my k8s cluster and 2 worker nodes to deploy my workloads on. Here is an example of my setup:

Some notes to the example:
- I use static MAC addresses so my router can assign static IP's to the machines
- the ip_address is not used to deploy the machine, but used to assign the talos config to the machine
- vm_id is nice to know :) 
- all other defaults can be found in [_variables.tf](./_variables.tf)
```yaml
master_vms = {
    minisforum-master = {
        mac_address  = "00:00:00:a1:2b:cc"
        ip_address   = "192.168.1.100"
        vm_id        = 101
    }
}
worker_vms = {
    minisforum-worker-1 = {
        mac_address  = "00:00:00:a1:2b:cc"
        ip_address   = "192.168.1.101"
        vm_id        = 201
        cpu_cores    = 6
        memory       = 5120 #in mB
    }
    minisforum-worker-2 = {
        mac_address  = "00:00:00:a1:2b:cc"
        ip_address   = "192.168.1.102"
        vm_id        = 202
        cpu_cores    = 6 
        memory       = 5120 #in mB
    }
}
```

## Bootstrapping your Talo cluster and retrieving the talos & kubeconfig
Running your terraform plan will bootstrap a new talos cluster on the created vm's. Before fullly initializing the cluster, it will add a few patches to tell the cluster it needs some extra parameters for the metric server to fully function. After bootstrapping it will also deploy the metric server to the cluster. 

### Retrieving your kubeconfig & talosconfig files
Because terraform builds the cluster, it also has the configs somewhere stored within it's setup. To ectually start using your cluster you might need both the talos- & kubeconfig files. 
- `terraform output talosconfig`
- `terraform output kubeconfig`

Note: the kubeconfig contains the `EOT` tags, make sure to remove these before you start using it. 

## List-dns
The file list-dns is an easy way to find all dns entries within your cluster. It will create a pod and will search for all known dns entries. Simply run it with your kubeconfig setup