/*
    main.tf
    requires terraform 0.12.x
*/

#=== Deployment Config
resource "azurerm_app_service_plan" "serverFarm" {
  name                  = var.hostingPlanName
  location              = var.region
  resource_group_name 	= var.resourceGroupName

  sku {
    tier 		= var.skuTier
    size 		= var.skuSize
    capacity 	= var.skuCapacity
  }
}

resource "azurerm_monitor_autoscale_setting" "serverFarm_as" {
	count					= var.enableAutoScale == true ? 1 : 0

	name                  	= "${var.hostingPlanName}${var.autoscaleNamePostfix}"
	location              	= var.region
	resource_group_name   	= var.resourceGroupName
	target_resource_id		= azurerm_app_service_plan.serverFarm.id

	profile {
		name = var.autoscaleProfileName
		capacity {
			default = var.scaleMin
			minimum = var.scaleMin
			maximum = var.scaleMax
		}

		rule {
			metric_trigger {
				metric_name			= var.infraScaleMetricName
				metric_resource_id	= azurerm_app_service_plan.serverFarm.id
				time_grain			= "PT1M"
				statistic			= "Average"
				time_window			= "PT10M"
				time_aggregation	= "Average"
				operator			= "GreaterThan"
				threshold			= var.metricScaleUp
			}
			scale_action {
				direction	= "Increase"
				type		= "ChangeCount"
				value		= "1"
				cooldown	= "PT5M"
			}
		}

		rule {
			metric_trigger {
				metric_name			= var.infraScaleMetricName
				metric_resource_id	= azurerm_app_service_plan.serverFarm.id
				time_grain			= "PT1M"
				statistic			= "Average"
				time_window			= "PT10M"
				time_aggregation	= "Average"
				operator			= "LessThan"
				threshold			= var.metricScaleDown
			}
			scale_action {
				direction	= "Decrease"
				type		= "ChangeCount"
				value		= "1"
				cooldown	= "PT5M"
			}
		}
	}
}

output "serverFarmId" {
	value = azurerm_app_service_plan.serverFarm.id
}
