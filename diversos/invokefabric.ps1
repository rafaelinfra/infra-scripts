$User = "xxxxxxxxxxxxxxx"
$PWord = "xxxxxxxxxxxx" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord


# function Set-FabricAuthToken {
#    <#
#     .SYNOPSIS
#         Set authentication token for the Fabric service
#     #>
#    [CmdletBinding(SupportsShouldProcess)]
#    param
#    (
#       [string]$servicePrincipalId
#       ,
#       [string]$servicePrincipalSecret
#       ,
#       [PSCredential]$credential
#       ,
#       [string]$tenantId
#       ,
#       [switch]$reset
#       ,
#       [string]$apiUrl = 'https://api.fabric.microsoft.com'
#    )

#    if (!$reset) {
#       $azContext = Get-AzContext
#    }

#    if ($apiUrl) {
#       $global:apiUrl = $apiUrl
#    }

#    if (!$azContext) {
#       Write-Output "Getting authentication token"
#       if ($servicePrincipalId) {
#          $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $servicePrincipalId, ($servicePrincipalSecret | ConvertTo-SecureString -AsPlainText -Force)

#          Connect-AzAccount -ServicePrincipal -TenantId $tenantId -Credential $credential | Out-Null

#          Set-AzContext -Tenant $tenantId | Out-Null
#       }
#       elseif ($null -ne $credential) {
#          Connect-AzAccount -Credential $credential -Tenant $tenantId | Out-Null
#       }
#       else {
#          Connect-AzAccount | Out-Null
#       }
#       $azContext = Get-AzContext
#    }
#    if ($PSCmdlet.ShouldProcess("Setting Fabric authentication token for $($azContext.Account)")) {
#       Write-output "Connnected: $($azContext.Account)"

#       $global:tokenfabric = (Get-AzAccessToken -ResourceUrl $global:apiUrl).Token
#    }
# }



Set-FabricAuthToken -Credential $credential -Tenant '72b5f416-8f41-4c88-a6a0-bb4b91383888'

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $global:tokenfabric")

$response = Invoke-RestMethod 'https://api.fabric.microsoft.com/v1/workspaces/xxxxxxxxxxxxx/items/xxxxxxxxxxxxxxx/jobs/instances?jobType=Pipeline' -Method 'POST' -Headers $headers
$response | ConvertTo-Json