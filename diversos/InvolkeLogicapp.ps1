param (
    [parameter(Mandatory = $false)] [string] $webhook
    )

$baseuri = $webhook
$header = @{
    "Accept" = "text/json"
    "Content-Type" = "application/json"
}

Write-Output "Tentando conexão com o Webhook"
$uri_login = $baseuri
$body = @{"limittest"="10";
          "temp"="3"
         } | ConvertTo-Json
Invoke-RestMethod -Method Post $uri_login -Headers $header -Body $body





