$sub = "xxxxxxxxxxxxxxxxxxx" #Your SubscriptionId
$rg = "xxxxxxxxxxxxxxxxx"

#Choose specific subscription
Select-AzSubscription -SubscriptionId $sub

#Query all workflows and api connections
$workflows = Get-AzResource -ResourceGroupName $rg -ResourceType 'Microsoft.Logic/workflows'
$apiConnections = Get-AzResource -ResourceGroupName $rg -ResourceType 'Microsoft.Web/connections'
$apiInUseSet = New-Object System.Collections.Generic.HashSet[String]
$apiAllSet = New-Object System.Collections.Generic.HashSet[String]
$apis = @{}

#iterate through all workflows, pick all api connections that is currently using
foreach ($workflow in $workflows) {
    $workflowJson = az rest --method get --uri ($workflow.Id + '?api-version=2016-06-01')
    $apisInWorkflow = ($workflowJson | ConvertFrom-Json).properties.parameters.'$connections'.value.psobject.properties.value#.connectionName
    Write-Host ' '
    Write-Host 'Logic App: '  $workflow.Name -ForegroundColor Green
    Write-Host 'Has following API connections:'
    Write-Host $apisInWorkflow.connectionName -ForegroundColor Red
    foreach ($api in $apisInWorkflow) {
        $apiInUseSet.Add($api.connectionName) | Out-Null
    }
}

#Get all api connection names
foreach ($api in $apiConnections) {
    # handle API connections for Logic App V1 only
    if($api.Kind -ne "V1"){
        continue;
    }
    $apiAllSet.Add($api.Name) | Out-Null
    $apis.Add($api.Name, $api.ResourceId) | Out-Null
}

#Display API connection status
Write-Host ' '
Write-Host '=============================================='
Write-Host 'All API Connections:'
Write-Host $apiAllSet -ForegroundColor Green
Write-Host ' '
Write-Host 'API Connections In Use:'
Write-Host $apiInUseSet -ForegroundColor Red
Write-Host 'API details:'
$Tab = [char]9
foreach ($api in $apiInUseSet) {
    $apiProperties = (az rest --method get --uri ($apis[$api] + '?api-version=2016-06-01') | ConvertFrom-Json)#.properties.authenticatedUser.name
    Write-Host $apiProperties.name -ForegroundColor Red -NoNewline
    Write-Host $Tab $apiProperties.properties.authenticatedUser.name -ForegroundColor Red
}

#find all api connections that is not used
Write-Host ' '
Write-Host 'API Connections NOT In Use:'
$apiAllSet.ExceptWith($apiInUseSet)
Write-Host $apiAllSet -ForegroundColor Yellow

#Delete all unused API connections if required
Write-Host '=============================================='
Write-Host ' '
Write-Host 'Enter ' -NoNewline
Write-Host 'DELETE' -NoNewline -ForegroundColor Yellow
$flag = Read-Host ' to delete all unused API connections, or any other key to exit...'
switch ($flag) {
    DELETE {
        foreach ($api in $apiAllSet) {
            Write-Host 'Deleting API connection: [' $api '] ...' -NoNewline
            az rest --method delete --uri ($apis[$api] + '?api-version=2016-06-01')
            Write-Host ' Completed'
        }
    }
    Default {}
}
Write-Host 'All done! Thanks for using!'