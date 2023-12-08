provider "azurerm" {
    features {}
}

variables {
    name_suffix = "test75"
    location    = "swedencentral"
}

run "setup_resource_group" {
    module {
        source  = "app.terraform.io/mattias-fjellstrom/resource-group-module/hashitalks"
        version = "2.0.1"
    }
}

run "setup_virtual_network" {
    variables {
        vnet_cidr_range = "10.0.0.0/16"
        resource_group = run.setup_resource_group.resource_group
        subnets = [
            {
                name              = "snet-1"
                subnet_cidr_range = "10.0.10.0/24"
            }
        ]
    }
    
    module {
        source  = "app.terraform.io/mattias-fjellstrom/network-module/hashitalks"
        version = "0.2.0"
    }
}

run "should_not_accept_arbitrary_environment" {
    command = plan
    
    variables {
        environment                  = "staging"
        azure_resource_group         = run.setup_resource_group.resource_group
        azure_virtual_network_subnet = run.setup_virtual_network.subnets[0]
        node_resource_group_name     = "rg-aks-resources-${var.name_suffix}" 
    }

    expect_failures = [
        var.environment,
    ]
}