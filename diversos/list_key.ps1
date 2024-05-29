az login --service-principal -u $US_SP -p $PWD_SP --tenant $TENANT

az account set --subscription $SUBS_NAME

$token = (Get-AzAccessToken -ResourceUrl "https://management.azure.com/").Token

$url = "https://management.azure.com/subscriptions/xxxxxxxxx/resourceGroups/xxxxxxxxxxxx/providers/Microsoft.Storage/storageAccounts/xxxxxxxxxxx/listKeys?api-version=2023-01-01&$expand=kerb"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers

if ($response) {
    Write-Output "Chave 1: $($response.keys[0].value)"
    Write-Output "Chave 2: $($response.keys[1].value)"
} else {
    Write-Output "Erro na solicitação."
}