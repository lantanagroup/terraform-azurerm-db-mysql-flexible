# Azure Database for MySQL Flexible Server

Azure Managed DB - MySQL flexible

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/claranet/db-mysql-flexible/azurerm/)

This Terraform module creates an [Azure MySQL flexible server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server)
with [databases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_database)
and associated admin users along with logging activated and
[firewall rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule).

Following MySQL configuration options are set by default and can be overridden with the `mysql_options` variable or
fully disabled by setting the variable `mysql_recommended_options_enabled` to `false`:
```
slow_query_log: ON
long_query_time: 5
interactive_timeout: 28800
wait_timeout: 28800
innodb_change_buffering: all
innodb_change_buffer_max_size: 50
innodb_print_all_deadlocks: ON
max_allowed_packet: 1073741824 # 1GB
explicit_defaults_for_timestamp: OFF
sql_mode: ERROR_FOR_DIVISION_BY_ZERO,STRICT_TRANS_TABLES
sql_generate_invisible_primary_key: OFF # MySQL 8 only
transaction_isolation: READ-COMMITTED
```
MySQL options for SSL and audit logs can be respectively enabled with the `ssl_enforced` and `mysql_audit_logs_enabled` variables.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | ~> 1.2, >= 1.2.22 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.75 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | ~> 1.2, >= 1.2.22 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.75 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics) | claranet/diagnostic-settings/azurerm | ~> 6.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mysql_flexible_database.mysql_flexible_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_database) | resource |
| [azurerm_mysql_flexible_server.mysql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | resource |
| [azurerm_mysql_flexible_server_active_directory_administrator.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_active_directory_administrator) | resource |
| [azurerm_mysql_flexible_server_configuration.mysql_flexible_server_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_configuration) | resource |
| [azurerm_mysql_flexible_server_firewall_rule.azure_services](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule) | resource |
| [azurerm_mysql_flexible_server_firewall_rule.firewall_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule) | resource |
| [random_password.mysql_administrator_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurecaf_name.mysql_flexible_databases](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.mysql_flexible_name](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurerm_client_config.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | MySQL administrator login. Required when create\_mode is Default. | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | MySQL administrator password. If not set, randomly generated | `string` | `null` | no |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | Map of authorized CIDRs | `map(string)` | `{}` | no |
| <a name="input_azure_services_access_enabled"></a> [azure\_services\_access\_enabled](#input\_azure\_services\_access\_enabled) | Whether to allow Azure services to access the MySQL Flexible server. | `bool` | `false` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention days for the server, supported values are between `7` and `35` days. | `number` | `10` | no |
| <a name="input_client_name"></a> [client\_name](#input\_client\_name) | Client name/account used in naming | `string` | n/a | yes |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | The creation mode which can be used to restore or replicate existing servers. | `string` | `"Default"` | no |
| <a name="input_custom_diagnostic_settings_name"></a> [custom\_diagnostic\_settings\_name](#input\_custom\_diagnostic\_settings\_name) | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| <a name="input_custom_server_name"></a> [custom\_server\_name](#input\_custom\_server\_name) | Custom Server Name identifier | `string` | `null` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Map of databases with default collation and charset. | `map(map(string))` | `{}` | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | The ID of the virtual network subnet to create the MySQL Flexible Server. | `string` | `null` | no |
| <a name="input_entra_authentication"></a> [entra\_authentication](#input\_entra\_authentication) | Azure Entra authentication configuration block for this Azure MySQL Flexible Server. You have to assign `Directory Readers` Azure Entra role to the User Assigned Identity, see [documentation](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-azure-ad#configure-the-microsoft-entra-admin). See dedicated [example](examples/entra-auth/modules.tf). | <pre>object({<br/>    user_assigned_identity_id = optional(string, null)<br/>    login                     = optional(string, null)<br/>    object_id                 = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment | `string` | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Map of custom tags | `map(string)` | `{}` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Turn Geo-redundant server backups on/off. Not available for the Burstable tier. | `bool` | `true` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | Map of high availability configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-high-availability. `null` to disable high availability | <pre>object({<br/>    mode                      = string<br/>    standby_availability_zone = optional(number)<br/>  })</pre> | <pre>{<br/>  "mode": "SameZone",<br/>  "standby_availability_zone": 1<br/>}</pre> | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | A list of User Assigned Managed Identity IDs to be assigned to this MySQL Flexible Server. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short string for Azure location. | `string` | n/a | yes |
| <a name="input_logs_categories"></a> [logs\_categories](#input\_logs\_categories) | Log categories to send to destinations. | `list(string)` | `null` | no |
| <a name="input_logs_destinations_ids"></a> [logs\_destinations\_ids](#input\_logs\_destinations\_ids) | List of destination resources IDs for logs diagnostic destination.<br/>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br/>If you want to specify an Azure EventHub to send logs and metrics to, you need to provide a formated string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the `|` character. | `list(string)` | n/a | yes |
| <a name="input_logs_metrics_categories"></a> [logs\_metrics\_categories](#input\_logs\_metrics\_categories) | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Map of maintenance window configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-maintenance | `map(number)` | `null` | no |
| <a name="input_mysql_audit_logs_enabled"></a> [mysql\_audit\_logs\_enabled](#input\_mysql\_audit\_logs\_enabled) | Whether MySQL audit logs are enabled. Categories `CONNECTION`, `ADMIN`, `CONNECTION_V2`, `DCL`, `DDL`, `DML`, `DML_NONSELECT`, `DML_SELECT`, `GENERAL` and `TABLE_ACCESS` are set by default when enabled<br/>  and can be overridden with variable `mysql_options`. See https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-audit-logs#configure-audit-logging." | `bool` | `false` | no |
| <a name="input_mysql_options"></a> [mysql\_options](#input\_mysql\_options) | Map of MySQL configuration options: https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html. See README file for defaults. | `map(string)` | `{}` | no |
| <a name="input_mysql_recommended_options_enabled"></a> [mysql\_recommended\_options\_enabled](#input\_mysql\_recommended\_options\_enabled) | Whether this module recommended MySQL options are set. | `bool` | `true` | no |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | MySQL server version. Valid values are `5.7` and `8.0.21` | `string` | `"8.0.21"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_point_in_time_restore_time_in_utc"></a> [point\_in\_time\_restore\_time\_in\_utc](#input\_point\_in\_time\_restore\_time\_in\_utc) | The point in time to restore from creation\_source\_server\_id when create\_mode is PointInTimeRestore. Changing this forces a new MySQL Flexible Server to be created. | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The ID of the private dns zone to create the MySQL Flexible Server. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | The size for the MySQL Flexible Server. | `string` | `"Standard_D2ds_v4"` | no |
| <a name="input_source_server_id"></a> [source\_server\_id](#input\_source\_server\_id) | The resource ID of the source MySQL Flexible Server to be restored. | `string` | `null` | no |
| <a name="input_ssl_enforced"></a> [ssl\_enforced](#input\_ssl\_enforced) | Enforce SSL connection on MySQL provider and set require\_secure\_transport on MySQL Server | `bool` | `true` | no |
| <a name="input_stack"></a> [stack](#input\_stack) | Project stack name | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Map of the storage configuration | <pre>object({<br/>    auto_grow_enabled  = optional(bool, true)<br/>    size_gb            = optional(number)<br/>    io_scaling_enabled = optional(bool, false)<br/>    iops               = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Tier for MySQL flexible server SKU. Possible values are: `GeneralPurpose`, `Burstable`, `MemoryOptimized`. | `string` | `"GeneralPurpose"` | no |
| <a name="input_use_caf_naming"></a> [use\_caf\_naming](#input\_use\_caf\_naming) | Use the Azure CAF naming provider to generate default resource name. `custom_server_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_use_caf_naming_for_databases"></a> [use\_caf\_naming\_for\_databases](#input\_use\_caf\_naming\_for\_databases) | Use the Azure CAF naming provider to generate databases name. | `bool` | `false` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Specifies the Availability Zone in which this MySQL Flexible Server should be located. Possible values are 1, 2 and 3 | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mysql_administrator_login"></a> [mysql\_administrator\_login](#output\_mysql\_administrator\_login) | Administrator login for MySQL server |
| <a name="output_mysql_administrator_password"></a> [mysql\_administrator\_password](#output\_mysql\_administrator\_password) | Administrator password for MySQL server |
| <a name="output_mysql_flexible_database_ids"></a> [mysql\_flexible\_database\_ids](#output\_mysql\_flexible\_database\_ids) | The list of all database resource IDs |
| <a name="output_mysql_flexible_databases"></a> [mysql\_flexible\_databases](#output\_mysql\_flexible\_databases) | Map of databases infos |
| <a name="output_mysql_flexible_databases_names"></a> [mysql\_flexible\_databases\_names](#output\_mysql\_flexible\_databases\_names) | List of databases names |
| <a name="output_mysql_flexible_firewall_rule_ids"></a> [mysql\_flexible\_firewall\_rule\_ids](#output\_mysql\_flexible\_firewall\_rule\_ids) | Map of MySQL created firewall rules |
| <a name="output_mysql_flexible_fqdn"></a> [mysql\_flexible\_fqdn](#output\_mysql\_flexible\_fqdn) | FQDN of the MySQL server |
| <a name="output_mysql_flexible_server_id"></a> [mysql\_flexible\_server\_id](#output\_mysql\_flexible\_server\_id) | MySQL server ID |
| <a name="output_mysql_flexible_server_name"></a> [mysql\_flexible\_server\_name](#output\_mysql\_flexible\_server\_name) | MySQL server name |
| <a name="output_mysql_flexible_server_public_network_access_enabled"></a> [mysql\_flexible\_server\_public\_network\_access\_enabled](#output\_mysql\_flexible\_server\_public\_network\_access\_enabled) | Is the public network access enabled |
| <a name="output_mysql_flexible_server_replica_capacity"></a> [mysql\_flexible\_server\_replica\_capacity](#output\_mysql\_flexible\_server\_replica\_capacity) | The maximum number of replicas that a primary MySQL Flexible Server can have |
| <a name="output_mysql_options"></a> [mysql\_options](#output\_mysql\_options) | MySQL server configuration options. |
| <a name="output_terraform_module"></a> [terraform\_module](#output\_terraform\_module) | Information about this Terraform module |
<!-- END_TF_DOCS -->

## Related documentation

- Microsoft Azure documentation: [docs.microsoft.com/fr-fr/azure/mysql/flexible-server/overview](https://docs.microsoft.com/fr-fr/azure/mysql/flexible-server/overview)
- Microsoft Azure Entra authentication documentation: [learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-azure-ad#configure-the-microsoft-entra-admin](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-azure-ad#configure-the-microsoft-entra-admin)
