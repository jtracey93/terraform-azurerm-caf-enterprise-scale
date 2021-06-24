# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.63.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8200b669-cbc6-4e6c-b6d8-f4797f924074"
  tenant_id       = "f73a2b89-6c0e-4382-899f-ea227cd6b68f"
}

provider "azurerm" {
  alias = "connectivity"
  features {}
  subscription_id = "7d58dc5d-93dc-43cd-94fc-57da2e74af0d"
  tenant_id       = "f73a2b89-6c0e-4382-899f-ea227cd6b68f"
}

# Declare variables used by the module
variable "root_id" {
  type    = string
  default = "escon"
}
variable "root_name" {
  type    = string
  default = "ESTF NW Test"
}

# You can use the azurerm_client_config data resource to dynamically
# extract the current Tenant ID from your connection settings.

data "azurerm_client_config" "current" {}
# Call the caf-enterprise-scale module directly from the Github
# pinning to the pre-release 0.4.0 version

module "enterprise_scale" {
  source = "../../"

  providers = {
    azurerm.management   = azurerm
    azurerm.connectivity = azurerm.connectivity
  }

  root_parent_id = data.azurerm_client_config.current.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name

  library_path = "${path.root}/lib"

  deploy_management_resources    = true
  configure_management_resources = local.configure_management_resources
  subscription_id_management     = "8200b669-cbc6-4e6c-b6d8-f4797f924074"

  deploy_connectivity_resources    = true
  configure_connectivity_resources = local.configure_connectivity_resources
  subscription_id_connectivity     = "7d58dc5d-93dc-43cd-94fc-57da2e74af0d"
}


locals {
  configure_connectivity_resources = {
    settings = {
      hub_networks = [
        {
          enabled = true
          config = {
            address_space                   = ["10.87.0.0/16", ]
            location                        = "northeurope"
            enable_ddos_protection_standard = false
            dns_servers                     = ["1.1.1.1", "8.8.8.8"]
            bgp_community                   = ""
            subnets = [
              {
                name                      = "test-subnet-1"
                address_prefixes          = ["10.87.10.0/24"]
                network_security_group_id = ""
                route_table_id            = ""
              },
              {
                name                      = "test-subnet-2"
                address_prefixes          = ["10.87.11.0/24"]
                network_security_group_id = ""
                route_table_id            = ""
              }
            ]
            virtual_network_gateway = {
              enabled = false
              config = {
                address_prefix           = "10.87.254.0/24"
                gateway_sku_expressroute = ""
                gateway_sku_vpn          = ""
              }
            }
            azure_firewall = {
              enabled = false
              config = {
                address_prefix   = "10.87.255.0/24"
                enable_dns_proxy = false
                availability_zones = {
                  zone_1 = false
                  zone_2 = false
                  zone_3 = false
                }
              }
            }
          }
        },
      ]
      vwan_hub_networks = []
      ddos_protection_plan = {
        enabled = false
        config = {
          location = ""
        }
      }
      dns = {
        enabled = true
        config = {
          location          = "northeurope"
          public_dns_zones  = []
          private_dns_zones = []
        }
      }
    }
    location = null
    tags = {
      deployedBy = "terraform/azure/caf-enterprise-scale"
    }
    advanced = null
  }
  configure_management_resources = {
    settings = {
      log_analytics = {
        enabled = true
        config = {
          retention_in_days                           = 30
          enable_monitoring_for_arc                   = true
          enable_monitoring_for_vm                    = true
          enable_monitoring_for_vmss                  = true
          enable_solution_for_agent_health_assessment = true
          enable_solution_for_anti_malware            = true
          enable_solution_for_azure_activity          = true
          enable_solution_for_change_tracking         = true
          enable_solution_for_service_map             = true
          enable_solution_for_sql_assessment          = true
          enable_solution_for_updates                 = true
          enable_solution_for_vm_insights             = true
          enable_sentinel                             = true
        }
      }
      security_center = {
        enabled = true
        config = {
          email_security_contact             = "security_contact@replace_me"
          enable_defender_for_acr            = true
          enable_defender_for_app_services   = true
          enable_defender_for_arm            = true
          enable_defender_for_dns            = true
          enable_defender_for_key_vault      = true
          enable_defender_for_kubernetes     = true
          enable_defender_for_servers        = true
          enable_defender_for_sql_servers    = true
          enable_defender_for_sql_server_vms = true
          enable_defender_for_storage        = true
        }
      }
    }
    location = "northeurope"
    tags     = null
    advanced = null
  }
}
