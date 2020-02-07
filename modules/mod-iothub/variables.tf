/*
    variables.tf
    requires terraform 0.12.x
*/

#=== Authentication
variable subscriptionId {}

#=== Location
variable region {}
variable environment {}
variable location {}
variable resourceGroupName {}

#=== IotHub
variable iothubName {
    default = "example"
}
variable iothubSkuName {
    default = "S1"
}
variable iothubSkuCapacity {
    default = 1
}
variable iothubEndpoints {
    type    = map
    default = {}
    /*
        {
            endpoint1 = {
                type                        Required:String (AzureIotHub.StorageContainer|AzureIotHub.ServiceBusQueue|AzureIotHub.ServiceBusTopic|AzureIotHub.EventHub)
                connectionString            Required:String
                name                        Required:String
                batchFrequencyInSeconds     Optional:Integer (Required for AzureIotHub.StorageContainer)
                maxChunkSizeInBytes         Optional:Integer (Required for AzureIotHub.StorageContainer)
                containerName               Optional:String (Required for AzureIotHub.StorageContainer)
                encoding                    Optional:String (avro|avrodeflate) (Required for AzureIotHub.StorageContainer)
                fileNameFormat              Optional:String (Default: {iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm})
            }
        }

    */
}
variable iothubIpFilterRules {
    type    = map
    default = {}
}
variable iothubRoutes {
    type    = map
    default = {}
}
variable iothubFallbackRoutes {
    type    = map
    default = {}
    /*
        {
            fallback1 = {
                source          Optional:String (RoutingSourceInvalid|RoutingSourceDeviceMessages|RoutingSourceTwinChangeEvents|RoutingSourceDeviceLifecycleEvents|RoutingSourceDeviceJobLifecycleEvents)
                condition       Optional:String (See: https://docs.microsoft.com/azure/iot-hub/iot-hub-devguide-query-language)
                endpointNames   Optional:List (Only one endpoint currently allowed) 
                enabled         Optional:Bool
            }
        }
    */
}
variable iothubFileUpload {
    type    = map
    default = {}
}
variable iothubConsumerGroups {
    type    = map
    default = {}
    /*
        {
            group1 = {
                name                    Required:String
                eventhubEndpointName    Required:String
            }
        }
    */
}