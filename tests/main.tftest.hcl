//--------------------------------------------------------------------------------------------------
// CONFIGURE PROVIDERS
//--------------------------------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

//--------------------------------------------------------------------------------------------------
// CONFIGURE GLOBAL VARIABLES
//--------------------------------------------------------------------------------------------------
variables {
  environment = "dev"
  name_suffix = "hashitalks-cluster"
  location    = "swedencentral"
}

//--------------------------------------------------------------------------------------------------
// SETUP DEPENDENCIES
//--------------------------------------------------------------------------------------------------
run "setup_resource_group" {
  module {
    source  = "app.terraform.io/mattias-fjellstrom/resource-group-module/hashitalks"
    version = "1.0.1"
    tags = {
      team        = "HashiTalks Team"
      project     = "HashiTalks Project"
      cost_center = "3214"
    }
  }
}

run "setup_virtual_network" {
  variables {
    vnet_cidr_range = "10.0.0.0/16"
    resource_group  = run.setup_resource_group.resource_group
    subnets = [
      {
        name              = "aks"
        subnet_cidr_range = "10.0.10.0/24"
      }
    ]
  }

  module {
    source  = "app.terraform.io/mattias-fjellstrom/network-module/hashitalks"
    version = "2.1.0"
  }
}

//--------------------------------------------------------------------------------------------------
// TESTS
//--------------------------------------------------------------------------------------------------
run "should_not_allow_invalid_environment" {
  command = plan

  variables {
    environment    = "staging"
    resource_group = run.setup_resource_group.resource_group
    subnet         = run.setup_virtual_network.subnets[0]
  }

  expect_failures = [
    var.environment,
  ]
}

run "dev_cluster_should_start_with_one_node" {
  command = plan

  variables {
    environment    = "dev"
    resource_group = run.setup_resource_group.resource_group
    subnet         = run.setup_virtual_network.subnets[0]
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].node_count == 1
    error_message = "Wrong number of initial nodes created for dev cluster"
  }
}

run "prod_cluster_should_start_with_three_nodes" {
  command = plan

  variables {
    environment    = "prod"
    resource_group = run.setup_resource_group.resource_group
    subnet         = run.setup_virtual_network.subnets[0]
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].node_count == 3
    error_message = "Wrong number of initial nodes created for prod cluster"
  }
}

run "setup_cluster" {
  variables {
    environment    = "prod"
    resource_group = run.setup_resource_group.resource_group
    subnet         = run.setup_virtual_network.subnets[0]
  }
}

provider "kubernetes" {
  host                   = run.setup_cluster.kube_config.host
  client_certificate     = base64decode(run.setup_cluster.kube_config.client_certificate)
  client_key             = base64decode(run.setup_cluster.kube_config.client_key)
  cluster_ca_certificate = base64decode(run.setup_cluster.kube_config.cluster_ca_certificate)
}

run "kubernetes_api_should_be_reachable" {
  variables {
    host                   = run.setup_cluster.kube_config.host
    cluster_ca_certificate = base64decode(run.setup_cluster.kube_config.cluster_ca_certificate)
  }

  providers = {
    kubernetes = kubernetes
  }

  module {
    source = "./testing/verify-aks"
  }

  assert {
    condition     = data.http.api.status_code == 200
    error_message = "Kubernetes API is not reachable"
  }
}