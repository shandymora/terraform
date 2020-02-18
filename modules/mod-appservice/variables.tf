#=== Authentication
variable subscriptionId {}

#=== location
variable environment {}             /* dev/uat/qa/prod/etc */
variable location {}                /* primary or secondary */
variable region {}                  /* eg. North Europe */
variable resourceGroupName {}       /* Needs to already exist */

#=== Site Config 
variable siteName {}
variable hostingPlanId {}                       /* Resource ID of the ServerFarm/App Service Plan */
variable httpsOnly {default = false }           /* Boolean */
variable defaultDocuments { 
    type = list(string)
    default = [
        "Default.htm",
        "Default.html",
        "Default.asp",
        "index.htm",
        "index.html",
        "iisstart.htm",
        "default.aspx",
        "index.php",
        "hostingstart.html"
    ]
}
#=== Slot 
variable slotName { default = "staging" }   /* Slot name */
