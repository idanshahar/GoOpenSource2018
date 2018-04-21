
provider "azurerm" {
  subscription_id = "..."
  client_id       = "..."
  client_secret   = "..."
  tenant_id       = "..."
  version         = "1.3.3"
}


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
      key_data = "${SSH_KEY}"
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
# hcl language
# https://github.com/hashicorp/hcl
# https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html