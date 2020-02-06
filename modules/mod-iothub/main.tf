/*
    main.tf
    requires terraform 0.12.x
*/

#=== Local variables
locals {
    envloc       = "${var.environment}-${var.location}"
    namePrefix    = "${var.iothubName}-${local.envloc}"
}

#=== Resource definitions
resource "azurerm_iothub" "iothub" {
    name                = local.namePrefix
    resource_group_name = var.resourceGroupName
    location            = var.region

    sku {
        name     = var.iothubSkuName
        capacity = var.iothubSkuCapacity
    }

    dynamic endpoint {
        for_each = var.iothubEndpoints

        content {
            type                        = endpoint.value.type
            connection_string           = endpoint.value.connectionString
            name                        = endpoint.value.name
            batch_frequency_in_seconds  = lookup(endpoint.value, "batchFrequencyInSeconds", null)
            max_chunk_size_in_bytes     = lookup(endpoint.value, "maxChunkSizeInBytes", null)
            container_name              = lookup(endpoint.value, "containerName", null)
            encoding                    = lookup(endpoint.value, "encoding", null)
            file_name_format            = lookup(endpoint.value, "fileNameFormat", null)
        }
    }

    dynamic ip_filter_rule {
        for_each = var.iothubIpFilterRules

        content {
            name        = ip_filter_rule.value.name
            ip_mask     = ip_filter_rule.ipMask
            action      = ip_filter_rule.action
        }
    }

    dynamic route {
        for_each = var.iothubRoutes

        content {
            name            = route.value.name
            source          = route.value.source
            condition       = lookup(route.value, "condition", null)
            endpoint_names  = route.value.endpointNames
            enabled         = route.value.enabled
        }
    }

    dynamic fallback_route {
        for_each = var.iothubFallbackRoutes

        content {
            source          = lookup(fallback_route.value, "source", null)
            condition       = lookup(fallback_route.value, "condition", null)
            endpoint_names  = lookup(fallback_route.value, "endpointNames", null)
            enabled         = lookup(fallback_route.value, "enabled", null)
        }
    }

    dynamic file_upload {
        for_each = var.iothubFileUpload

        content {
            connection_string       = file_upload.value.connectionString
            container_name          = file_upload.value.containerName
            sas_ttl                 = lookup(file_upload.value, "sasTtl", null)
            notifications           = lookup(file_upload.value, "notifications", null)
            lock_duration           = lookup(file_upload.value, "lockDuration", null)
            default_ttl             = lookup(file_upload.value, "defaultTtl", null)
            max_delivery_count      = lookup(file_upload.value, "maxDeliveryCount", null)
        }
    }
}
resource "azurerm_iothub_consumer_group" "group" {
    for_each = var.iothubConsumerGroups

    name                   = each.value.name
    iothub_name            = azurerm_iothub.racadv.name
    eventhub_endpoint_name = each.value.eventhubEndpointName
    resource_group_name    = var.resourceGroupName
}
