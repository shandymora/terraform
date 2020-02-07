/*
    main.tf
    requires terraform 0.12.x
*/


#=== Deployment Config
resource "azurerm_app_service" "appservice" {
    name                    = var.siteName
    location                = var.region
    resource_group_name     = var.resourceGroupName
    app_service_plan_id     = var.hostingPlanId
    https_only              = var.httpsOnly
    

    site_config {
        always_on   = true
        default_documents = var.defaultDocuments
    }
}

resource "azurerm_app_service_slot" "stagingslot" {
    name                    = var.slotName
    app_service_name        = azurerm_app_service.as.name
    location                = var.region
    resource_group_name     = var.resourceGroupName
    app_service_plan_id     = var.hostingPlanId
    https_only              = var.httpsOnly
   
}

resource "azurerm_application_insights" "appinsights" {
  name                = var.siteName
  location            = var.region
  resource_group_name = var.resourceGroupName
  application_type    = "web"
}

output "WebAppName" {
  value = azurerm_app_service.as.name
}
output "AppInsightsAPIKey" {
  value = azurerm_application_insights.appinsights.instrumentation_key
}

