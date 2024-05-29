# param (
  
#     [Parameter(Mandatory=$true)] 
#     [String] $VMName,
#     [Parameter(Mandatory=$true)] 
#     [String] $ResourceGroupName,
#     #utilizando o varible do próprio recurso
#     [Parameter(Mandatory=$true)]
#     [String] $Subscription
# )
# Subscription
# $SubscriptionId = Get-AutomationVariable -Name $Subscription

# Connect to Azure with system-assigned managed identity
az login --identity

# set context
az account set --subscription 'xxxxxxxxxxxxxxxx'


az storage fs access update-recursive --acl "default:<USERORGROUP>:<OBJECTIDUSERORGROUP>:r-x" -p <PATH> -f insights-activity-logs --account-name xxxxxxx --auth-mode login && az storage fs access update-recursive --acl "<USERORGROUP>:<OBJECTIDUSERORGROUP>:r-x" -p <PATH> -f insights-activity-logs --account-name xxxxx --auth-mode login