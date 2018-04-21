Go Open Source 2018 - Nodeless Jenkins Pipeline
=================================
Presentation
------------
[Nodeless Jenkins Pipeline](https://ptdrv.linkedin.com/dif0yfi)

Prerequisites
------------
1. Terraform - [Installation Instructions](https://www.terraform.io/intro/getting-started/install.html)
2. Helm - [Installation Instructions](https://github.com/kubernetes/helm/blob/master/docs/install.md)
3. Draft - [Installation Instructions](https://github.com/Azure/draft/blob/master/docs/install.md)
4. kubectl - [Installation Instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
5. Docker - [Installation Instructions](https://docs.docker.com/install/)
6. Azure CLI - [Installation Instructions](https://docs.docker.com/install/) 

 A running Kubernetes Cluster - [AKS Instructions](https://azure.github.io/projects/clis/)


Setup Azure Managed Kubernetes Cluster using Terraform
------------------------------------------------------
### Terraform AKS Configuration .tf
```
resource "azurerm_resource_group" "test" {
  name     = "my_terraform_k8s"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "aks-terraform"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  dns_prefix          = "acstestagent1"

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = "${YOUR_SSH_KEY}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_DS1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${SPN_APP_ID}"
    client_secret = "${SPN_PASSWORD}"
  }

  tags {
    Environment = "Production"
  }
}
```

### Deploy an AKS Cluster
```
# run this inside your terraform configuration directory

terraform init

terraform plan -out=tfplan -input=false

terraform apply tfplan
```

### Delete the Cluster
```
# run this inside your terraform configuration directory

terraform destroy . 
```
### Get the Cluster Credentials
```
az aks get-credentials -n aks-terraform -g my_terraform_k8s

```

Nodeless Jenkins on Kubernetes
------------------------------
### Set up Jenkins using helm

[![asciicast](https://asciinema.org/a/OZqZ4kN3GeqSsj63DxhgiSgvD.png)](https://asciinema.org/a/OZqZ4kN3GeqSsj63DxhgiSgvD?size=small)

```
# if this is the first time you are using helm, please uncomment the line below.

# helm init

helm install --name jenkins stable/jenkins

# Alternatively, if you are having issues with the persistant volume class, you can still install jenkins from the chart provided in this repo:
# helm install --name jenkins jenkins-helm/.
# or to pass the storage class parameter:
helm install --name jenkins stable/jenkins --set Persistence.StorageClass=default

# the provided chart also Adds ACI plugin and Azure AD plugin (needs to be configured though)
```
### Get Jenkins admin password
```
printf $(kubectl get secret --namespace default jenkins-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```
### Build a Docker Image for Jenkins Slave on your own
```
git clone https://github.com/idanshahar/K8SCodeComponentsMeetup.git

cd KubernetesCodeComponents/jenkins

docker build . --tag ${YOUR_DOCKER_REGISTRY}:${TAG}

docker push ${YOUR_DOCKER_REGISTRY}:${TAG}
```

### Jenkins Configuration
Go to "Manage Jenkins" -> "Configure System"

1. Under Container Template, change the Docker Image to: idanshahar/jenkins-slave:latest
2. Add the following host path volumes: /var/run/docker.sock, /usr/bin/docker 
3. Create a new Pipeline job and select the jenkins file from git
4. Change kubernetes url to 10.0.0.1

Go to "Credentials" -> "System" -> "Global credentials" -> "Add Credentials"

1. Choose "Global" Scope
2. Add your Dockerhub credentials
3. Insert 'docker-hub-credentials' as the credentialls ID 

Containerize applications using Draft
-------------------------------------
```
# cd to your app root folder
cd node-draft

draft init #initialize draft

draft create 

draft up
```
