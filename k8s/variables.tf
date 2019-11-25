variable "client_id" {}
variable "client_secret" {}

variable "kubernetes_version" {
  type    = string
  default = "1.14.8"
}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
    type = string
}

variable "dns_prefix" {
    default = "abrigk8stest"
}

variable cluster_name {
    description = "Name of the cluster"
    default = "abrigk8stest"
}

variable resource_group_location {
    description = "The Azure location we want resources to reside"
    default = "westus"
}

variable log_analytics_workspace_name {
    default = "abrigLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}