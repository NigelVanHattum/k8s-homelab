# Deploying the base resources for the k8s cluster

## 1Password (secret manager)
1Password is used as the secret storage for all variables that Terraform needs during rollout of all resources. 
Terraform uses a single service token that will allow you to connect to your secrets. To create your service token, follow [the guide provided by 1Password itself](https://developer.1password.com/docs/service-accounts/get-started/). 

## Linkerd
- [Linkerd homepage](https://linkerd.io/)
- [Linkerd Helm Chart](https://linkerd.io/2.14/tasks/install-helm/)

[!NOTE]
Using the Linkerd CNI is not an option, this is caused by Talos OS which does not include the "nsenter" package. 

Linkerd will be installed with a self-signed root-ca that is valid for 10 years. Nothing more to say about Linkerd.

# Old docs, need updates
Linkerd is used to enable secure traffic throughout the whole cluster. Linkerd should be the first thing you install, this will effect all deployments that come after. 

- **azure_tenant_id, azure_client_id & azure_client_secret**: ArgoCD uses this as authentication, follow [their guide] (https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/microsoft/) **TODO: automate this**
- **cloudlfare_dns_api_token**: I use Cloudflare as my DNS provider, follow [this guide](https://go-acme.github.io/lego/dns/cloudflare/) to get your DNS API key.
- **passwords and tokens**: feel free to create your own secret. But store them somewhere in a password manager, in case you need a recovery. 

```bash
$ cd 03_linkerd
$ terraform init
$ terraform plan -out plan.tfplan
$ terraform apply plan.tfplan 
```

## 04_ArgoCD
Argo is deployed using Terraform. Follow the script that will deploy argoCD. ArgoCD also tries to allow OIDC connections, follow [this guide](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/microsoft/#azure-ad-app-registration-auth-using-oidc). 

```bash
$ cd 04_argocd
$ terraform init
$ terraform plan -out plan.tfplan
$ terraform apply plan.tfplan 
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
$ kubectl port-forward svc/argocd-server 8080:80 -n argo
$ echo "Login with admin:$(kubectl get secrets -n argo -o json argocd-admin-password | jq -r '.data.password' | base64 -d)"
```

## 05_Storage
In order to have a seperate storage provider, I am using a NFS provider. Deployment of this chart is done through ArgoCD. 

```bash
$ cd 05_storage
$ terraform init
$ terraform plan -out plan.tfplan
$ terraform apply plan.tfplan 
```

## 06_Networking
Below is some information about everything that is deploy with the following script:
```bash
$ cd 06_networking
$ terraform init
$ terraform plan -out plan.tfplan
$ terraform apply plan.tfplan 
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

Let's encrypt setup is done following the following example: 
- https://github.com/traefik/traefik-helm-chart/blob/master/EXAMPLES.md#use-traefik-native-lets-encrypt-integration-without-cert-manager
- https://go-acme.github.io/lego/dns/cloudflare/


There were some permission issues, they are solve by introducting the init-container

## 07_database

### PostgreSQL
PostgreSQL is deployed via the Bitname postgresql-ha helm chart using ArgoCD. You will be asked to create a password for the postgres user. 

If you ever forget the password, here is how to retrieve it:

```Bash
kubectl get secret "postgres-admin-password" -o json -n postgresql | jq -r ".[\"data\"][\"password\"]" | base64 -d 
```

### 07_01_management
The database is not exposed outside the cluster, to connect to the database you first need to port-forward the database port: 
```Bash
kubectl port-forward service/postgresql-postgresql-ha-pgpool 5432:5432 -n postgresql
```

After port forwarding you are able to directly connect to your database. This will allow you to create your users/ databases. 
```bash
$ cd 07_01_management
$ terraform init
$ terraform plan -out plan.tfplan
$ terraform apply plan.tfplan 
```

The postgres-ha helm chart does not auto update the pgpool secret pods whenever the secret changes. Make sure to restart your pgpool pod, in order to allow new users to connect. 

## 08_authentication
For system wide authentication I've choosen to go with Authentik. 

### GeoIP acces
To allow some geo data with your acces log you can enable GeoIP logging. To enable this, follow this guide: https://goauthentik.io/docs/core/geoip. The setup is present in de default helm-values.

### Azure - Entra ID
In order to add your Azure Entra ID, following [this guide](https://goauthentik.io/integrations/sources/azure-ad/) and use the variables.