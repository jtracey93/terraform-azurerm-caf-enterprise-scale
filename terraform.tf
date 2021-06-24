# Configure the minimum required providers supported by this module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.63.0"
      configuration_aliases = [ azurerm.management, azurerm.connectivity ]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }
  }
}
