# Subscription
$SubscriptionId = "xxxxxxx"

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# set context
Set-AzContext –SubscriptionId $SubscriptionId

$logicApps = Get-AzLogicApp | Where-Object { $_.State -eq 'Enabled' }

$logicApps | ForEach-Object {
    $logicAppName = $_.Name
    $resourceId = $_.Id
    $resourceGroupName = ($resourceId -split '/')[4]
    
    Write-Host "Desativando o Logic App: $logicAppName"
    Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -State 'Disabled' -Force
}