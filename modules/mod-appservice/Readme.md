


```terraform
module "site" {
  source = "git::http://10.24.253.6/terraform/mod-appservice.git?ref=master"

  subscriptionId		= var.subscriptionId
  region				= var.region
  environment			= var.environment
  location				= var.location
  resourceGroupName     = var.resourceGroupName

  siteName      = local.webappName
  hostingPlanId = module.server-farm.serverFarmId
  httpsOnly     = var.httpsOnly

}
```