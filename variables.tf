variable "app_service_logs" {
  type = list(object({
    disk_quota_mb = optional(string)
    retention_period_days = optional(number)
  }))
  default = [{}]
}

variable "app_service_plan_id" {
  type = string
}

variable "application_stack" {
  type = list(object({
    dotnet_version = optional(string)
    java_version = optional(string)
    node_version = optional(string)
    python_version = optional(string)
    powershell_core_version = optional(string)
    use_custom_runtime = optional(bool)
    use_dotnet_isolated_runtime = optional(bool)
    docker = optional(list(object({
      registry_url = string
      image_name = string
      image_tag = string
      registry_username = string
      registry_password = string
    })))
  }))
  default = [{}]
}

variable "cors" {
  type = object({
    allowed_origins = optional(set(string))
    support_credentials = optional(bool)
  })
  default = { }
}

variable "environment" {
  type = string
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "The Event Hub authorization rule ID for diagnostic settings."
  default     = "/subscriptions/56bdaed4-70cf-4a28-8fb8-0efc135bb29f/resourceGroups/LOGS_RG/providers/Microsoft.EventHub/namespaces/evh-sharedsvcseastus/authorizationRules/RootManageSharedAccessKey"
}

variable "eventhub_name" {
  type        = string
  description = "The Event Hub name for diagnostic settings."
  default     = "cs-resource_resourcelogs"
}

variable "identity_type" {
  type = string
  default = "SystemAssigned"
}

variable "ip_restriction" {
  type = list(object({
    action = optional(string, "Deny")
    headers = optional(list(object({
      x_azure_fdid = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for = optional(list(string))
      x_forwarded_host = optional(list(string))
    })))
    ip_address = optional(string)
    name = optional(string)
    priority = optional(number)
    service_tag = optional(string)
    virtual_network_subnet_id = optional(string)
    description = optional(string)
  }))
  default = [{}]
}

variable "https_only" {
  type = bool
  default = true
}

variable "location" {
  type = string
  default = "eastus"
}

variable "private_endpoint_dns_zone_ids" {
  type = list(string)
  default = [ "/subscriptions/56bdaed4-70cf-4a28-8fb8-0efc135bb29f/resourceGroups/rg-azuredns-prd-01/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net" ]
}

variable "private_endpoint_dns_zone_group_name" {
  type = string
  default = "default"
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "public_network_access_enabled" {
  type = bool
  default = false
}

variable "resource_group_name" {
  type = string
}


variable "scm_ip_restriction" {
  type = list(object({
    action = optional(string, "Deny")
    headers = optional(list(object({
      x_azure_fdid = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for = optional(list(string))
      x_forwarded_host = optional(list(string))
    })))
    ip_address = optional(string)
    name = optional(string)
    priority = optional(number)
    service_tag = optional(string)
    virtual_network_subnet_id = optional(string)
    description = optional(string)
  }))
  default = [{}]
}

variable "site_config" {
  type = object({
    always_on = optional(bool, false)
    api_definition_url = optional(string)
    api_management_api_id = optional(string)
    app_command_line = optional(string)
    app_scale_limit = optional(number)
    application_insights_connection_string = optional(string)
    application_insights_key = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity = optional(bool)
    default_documents = optional(list(string))
    elastic_instance_minimum = optional(number)
    ftps_state = optional(string)
    health_check_path = optional(string)
    health_check_eviction_time_in_min = optional(number)
    http2_enabled = optional(bool)
    ip_restriction_default_action = optional(string, "Deny")
    load_balancing_mode = optional(string)
    managed_pipeline_mode = optional(string)
    minimum_tls_version = optional(string, "1.2")
    pre_warmed_instance_count = optional(number)
    remote_debugging_enabled = optional(bool)
    remote_debugging_version = optional(string)
    runtime_scale_monitoring_enabled = optional(bool)
    scm_minimum_tls_version = optional(string, "1.2")
    scm_use_main_ip_restriction = optional(bool)
    use_32_bit_worker = optional(bool)
    vnet_route_all_enabled = optional(bool)
    websockets_enabled = optional(bool)
    worker_count = optional(number)
  })
  default = { }
}

variable "solution_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "vnet_integration_subnet_id" {
  type = string
  default = ""
}
