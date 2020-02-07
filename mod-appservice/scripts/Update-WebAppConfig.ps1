<#
    Author:         shandymora
    Description:    Update App Service Settings and Connection Strings
    Requires:       Powershell 5.x+
                    Azure Powershell Module (Az)
#>

<#
    .SYNOPSIS
        Update App Service Settings and Connection Strings

    .DESCRIPTION
        Update App Service Settings and Connection Strings.  Source can be a mix of local JSON configuration file
        and/or Key Vault Secrets

    .PARAMETER ResourceGroupName
        Required. Name of the resource group where the App Service is provisioned

    .PARAMETER WebAppName
        Required.  Name of the App Service resource

    .PARAMETER AppSettingsString
        Optional.  Setting/Environment variable to add to the App Service.

    .PARAMETER Replace
        Optional.  Update/replace an existing setting

    .PARAMETER ConnectionStrings
        Optional.  Is it a connection string?

#>
Param (
    [string]$ResourceGroupName,
    [string]$WebAppName,
    [string]$AppSettingsString,
    [switch]$Replace,
    [switch]$ConnectionStrings
)

function Update-AppSettings {
    if ($Replace) {
        #== Update WebApp with merged appsettings
        Set-AzWebApp -AppSettings $AppSettings -Name $WebAppName -ResourceGroupName $ResourceGroupName
    } else {
        #== Get WebApp 
        $webapp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
        $originalAppSettings = $webapp.SiteConfig.AppSettings
    
        #== Merge original and new App Settings
        foreach ($setting in $originalAppSettings) {
            if ( $AppSettings.Contains($setting.Name) ) {
                $originalAppSettings.Remove($setting)
            } else {
                $AppSettings.Add($setting.Name, $setting.Value)
            }
        }
    
        #== Update WebApp with merged appsettings
        Set-AzWebApp -AppSettings $AppSettings -Name $WebAppName -ResourceGroupName $ResourceGroupName
    }
}

function Update-ConnectionStrings {

}

if ($AppSettings) {
    $AppSettings = ConvertFrom-StringData -StringData $AppSettingsString
    Update-AppSettings
}
if ($ConnectionStrings) {
    Update-ConnectionStrings
}
