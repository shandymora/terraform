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