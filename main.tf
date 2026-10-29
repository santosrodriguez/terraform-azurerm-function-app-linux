terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_string" "suffix" {
  length = 4
  min_special = 0
  min_upper = 0
}

data "azurecaf_name" "linux_function_app" {
  resource_type = "azurerm_function_app"
  suffixes = [ var.solution_name, var.location, var.environment, random_string.suffix.result ]
}

resource "azurerm_linux_function_app" "linux_function_app" {
  location = var.location
  name = data.azurecaf_name.linux_function_app.result
  resource_group_name = var.resource_group_name
  service_plan_id = var.app_service_plan_id
  storage_account_name = try(var.storage_account_name, null)
  public_network_access_enabled = var.public_network_access_enabled
  https_only = var.https_only
  virtual_network_subnet_id = var.vnet_integration_subnet_id
  site_config {
    always_on = var.site_config.always_on
    api_definition_url = var.site_config.api_definition_url
    api_management_api_id = var.site_config.api_management_api_id
    app_command_line = var.site_config.app_command_line
    app_scale_limit = var.site_config.app_scale_limit
    application_insights_connection_string = var.site_config.application_insights_connection_string
    application_insights_key = var.site_config.application_insights_key
    dynamic "application_stack" {
      for_each = { for k, v in var.application_stack : k => v }
      content {
        dotnet_version = application_stack.value.dotnet_version
        java_version = application_stack.value.java_version
        node_version = application_stack.value.node_version
        powershell_core_version = application_stack.value.powershell_core_version
        python_version = application_stack.value.python_version
        use_custom_runtime = application_stack.value.use_custom_runtime
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
        dynamic "docker" {
          for_each = application_stack.value.docker == null ? [] :  application_stack.value.docker
          content {
            registry_url = docker.value.registry_url
            registry_password = docker.value.registry_password
            registry_username = docker.value.registry_username
            image_name = docker.value.image_name
            image_tag = docker.value.image_tag
          }
        }
      }
    }
    dynamic "app_service_logs" {
      for_each = { for k, v in var.app_service_logs : k => v }
      content {
        disk_quota_mb = app_service_logs.value.disk_quota_mb
        retention_period_days = app_service_logs.value.retention_period_days
      }
    }
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity = var.site_config.container_registry_use_managed_identity
    dynamic "cors" {
      for_each = var.cors == null ? [] : [ var.cors ]
      content {
        allowed_origins = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }    
    default_documents = var.site_config.default_documents
    ftps_state = var.site_config.ftps_state
    health_check_eviction_time_in_min = var.site_config.health_check_eviction_time_in_min
    health_check_path = var.site_config.health_check_path
    http2_enabled = var.site_config.http2_enabled
    dynamic "ip_restriction" {
      for_each = var.ip_restriction == null ? [] : var.ip_restriction 
      content {
        action = ip_restriction.value.action
        headers = ip_restriction.value.headers
        ip_address = ip_restriction.value.ip_address
        priority = ip_restriction.value.priority
        service_tag = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }
    ip_restriction_default_action = var.site_config.ip_restriction_default_action
    managed_pipeline_mode = var.site_config.managed_pipeline_mode
    minimum_tls_version = var.site_config.minimum_tls_version
    pre_warmed_instance_count = var.site_config.pre_warmed_instance_count
    remote_debugging_enabled = var.site_config.remote_debugging_enabled
    remote_debugging_version = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled = var.site_config.runtime_scale_monitoring_enabled
    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restriction == null ? [] : var.scm_ip_restriction 
      content {
        action = scm_ip_restriction.value.action
        headers = scm_ip_restriction.value.headers
        ip_address = scm_ip_restriction.value.ip_address
        priority = scm_ip_restriction.value.priority
        service_tag = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
      }
    }
    scm_minimum_tls_version = var.site_config.scm_minimum_tls_version
    use_32_bit_worker = var.site_config.use_32_bit_worker
    vnet_route_all_enabled = var.site_config.vnet_route_all_enabled
    websockets_enabled = var.site_config.websockets_enabled
    worker_count = var.site_config.worker_count
  }
  identity {
    type = var.identity_type
  }
}

resource "azurerm_private_endpoint" "linux_func_app_pep" {
  name = "pe-${azurerm_linux_function_app.linux_function_app.name}"
  location = azurerm_linux_function_app.linux_function_app.location
  resource_group_name = azurerm_linux_function_app.linux_function_app.resource_group_name
  subnet_id = var.private_endpoint_subnet_id
  private_service_connection {
    name = "pe-connection-${azurerm_linux_function_app.linux_function_app.name}"
    is_manual_connection = false
    private_connection_resource_id = azurerm_linux_function_app.linux_function_app.id
    subresource_names = ["sites"]
  }
  private_dns_zone_group {
    name = var.private_endpoint_dns_zone_group_name
    private_dns_zone_ids = var.private_endpoint_dns_zone_ids
  }
}

resource "azurerm_monitor_diagnostic_setting" "linux_func_app_diagnostic" {
  name = "diagsetting-${azurerm_linux_function_app.linux_function_app.name}"
  target_resource_id = azurerm_linux_function_app.linux_function_app.id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name = var.eventhub_name
  enabled_log {
    category = "FunctionAppLogs"
  }
}
