resource "azurerm_mysql_flexible_server" "mysql_flexible_server" {
  name = local.mysql_flexible_server_name

  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = local.administrator_password
  version                = var.mysql_version

  zone = var.zone

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  delegated_subnet_id          = var.delegated_subnet_id

  sku_name    = join("_", [lookup(local.tier_map, var.tier, "GeneralPurpose"), var.size])
  create_mode = var.create_mode

  source_server_id                  = var.source_server_id
  point_in_time_restore_time_in_utc = var.point_in_time_restore_time_in_utc

  private_dns_zone_id = var.private_dns_zone_id

  dynamic "high_availability" {
    for_each = toset(var.high_availability != null ? [var.high_availability] : [])

    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = lookup(high_availability.value, "standby_availability_zone", 1)
    }
  }

  dynamic "maintenance_window" {
    for_each = toset(var.maintenance_window != null ? [var.maintenance_window] : [])

    content {
      day_of_week  = lookup(maintenance_window.value, "day_of_week", 0)
      start_hour   = lookup(maintenance_window.value, "start_hour", 0)
      start_minute = lookup(maintenance_window.value, "start_minute", 0)
    }
  }

  dynamic "storage" {
    for_each = toset(var.storage != null ? [var.storage] : [])

    content {
      auto_grow_enabled  = var.storage.auto_grow_enabled
      size_gb            = var.storage.size_gb
      io_scaling_enabled = var.storage.io_scaling_enabled
      iops               = var.storage.iops
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  tags = merge(local.default_tags, var.extra_tags)

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
      create_mode,
    ]
    precondition {
      condition     = (var.storage.io_scaling_enabled && var.storage.iops == null) || (!var.storage.io_scaling_enabled && var.storage.iops != null)
      error_message = "You have to choose between enabling storage auto-scaling IO without defining storage IOPS or disabling storage auto-scaling IO with defined storage IOPS."
    }
  }
}

resource "azurerm_mysql_flexible_database" "mysql_flexible_db" {
  for_each = var.databases

  name                = var.use_caf_naming_for_databases ? data.azurecaf_name.mysql_flexible_databases[each.key].result : each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_flexible_server.name
  charset             = lookup(each.value, "charset", "utf8")
  collation           = lookup(each.value, "collation", "utf8_general_ci")
}

resource "azurerm_mysql_flexible_server_configuration" "mysql_flexible_server_config" {
  for_each = local.mysql_options

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_flexible_server.name
  value               = each.value
}

resource "random_password" "mysql_administrator_password" {
  length           = 32
  special          = true
  override_special = "@#%&*()-_=+[]{}<>:?"
}

resource "azurerm_mysql_flexible_server_active_directory_administrator" "main" {
  count = length(var.entra_authentication.object_id[*]) > 0 ? 1 : 0

  server_id   = azurerm_mysql_flexible_server.mysql_flexible_server.id
  identity_id = var.entra_authentication.user_assigned_identity_id
  login       = var.entra_authentication.login
  object_id   = var.entra_authentication.object_id
  tenant_id   = data.azurerm_client_config.main.tenant_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule#example-usage-allow-access-to-azure-services
resource "azurerm_mysql_flexible_server_firewall_rule" "azure_services" {
  count = var.delegated_subnet_id == null && var.azure_services_access_enabled ? 1 : 0

  name                = "Azure-Services"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_flexible_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}