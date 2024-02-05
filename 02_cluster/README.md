# Manage your cluster via talosctl

## Install and upgrade talosctl
To install Talosctl, run the following commands
```bash
brew tap siderolabs/tap
brew install talosctl
```

### Updating Talosctl
Run
```bash
brew upgrade talosctl
```

## Update Talos OS
To upgrade your Talos OS you have to execute the update per node, therefor you will need to run this command for each node in your cluster. 
The command uses a few variables:
|Name|Note|
|---------------|--------------------------------------------------|
|config         |location to your talosconfig file                 |
|version        |Version you want your talos node to upgrade to    |
|node_ip        |Ip Address of the node you want to upgrade        |

If you are running a single control node run:
```bash
talosctl upgrade --talosconfig ${config} --preserve --image ghcr.io/siderolabs/installer:v${version} -n ${node_ip}
```

If you have multiple control nodes run:
```bash
talosctl upgrade --talosconfig ${config} --image ghcr.io/siderolabs/installer:v${version} -n ${node_ip}
```

## Update kubernetes
Updating the kubernetes cluster itself is also done through talosctl. Make sure the kubernetes version is compatible with your Talos OS version. You can find that information in the [support matrix](https://www.talos.dev/v1.6/introduction/support-matrix/) on the Talos website. 
Upgrading the cluster requires mostly the same paramaters:
|Name|Note|
|---------------|--------------------------------------------------|
|config         |location to your talosconfig file                 |
|version        |Version you want your kubernetes to upgrade to    |
|control_plane  |Ip Address of the controlplane of your cluster    |
```bash
talosctl --talosconfig ${config} -n ${control_plane} upgrade-k8s --to ${version}
```