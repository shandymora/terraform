/*
    main.tf
    requires terraform 0.12.x
*/

#=== Authentication 
variable subscriptionId {}

#=== location 
variable region {}
variable environment {}
variable location {}
variable resourceGroupName {}

#=== Server Farm
variable hostingPlanName {}
variable skuTier {}
variable skuSize {}
variable skuCapacity {}

#=== Auto Scaling 
variable enableAutoScale { default = false }
variable autoscaleProfileName { default = "Default" }
variable autoscaleNamePostfix { default = "-scale" }
variable scaleMin { default = "1" }
variable scaleMax { default = "10" }
variable infraScaleMetricName { default = "CpuPercentage" }
variable metricScaleUp { default = "70" }
variable metricScaleDown { default = "30" }


