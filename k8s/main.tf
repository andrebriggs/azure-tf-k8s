terraform {
  required_version = ">= 0.12"
}

terraform {
  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider

# Recomended to prevent automatic upgrades to new major versions that may contain breaking changes
provider "azurerm" {
  version = "~>1.32.1"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create templated resource group name and AKS cluster name based on random strings 
# ---------------------------------------------------------------------------------------------------------------------

locals {
    resource_group_name = "abrig-temp-rg-${random_string.default.result}"
    cluster_name = "abrig-k8s-${random_string.default.result}"

}

resource "azurerm_resource_group" "k8s" {
    name     = local.resource_group_name
    location = var.resource_group_location
}

resource "random_string" "default" {
  length = 6
  lower=true
  special=false
}

resource "random_string" "lower" {
  length  = 16
  upper   = false
  lower   = true
  number  = false
  special = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Deploy Azure Log Analytics that will be referenced from AKS install
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "test" {
    name                = var.log_analytics_workspace_name
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.k8s.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.test.location
    resource_group_name   = azurerm_resource_group.k8s.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

# ---------------------------------------------------------------------------------------------------------------------
# Deploy AKS instance that specifies VM SKU, service principal, and log analytics instance
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = local.cluster_name #var.cluster_name
    location            = azurerm_resource_group.k8s.location 
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix
    kubernetes_version  = var.kubernetes_version

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = var.agent_count
        vm_size         = "Standard_D1_v2"
        os_type         = "Linux"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
    }

    tags = {
        Environment = "Development"
    }
}