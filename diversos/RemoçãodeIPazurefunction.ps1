$ruleName = az functionapp config access-restriction show -g xxxxxxxxxxxxxx -n func-ipp-sandbox -o json | ConvertFrom-Json | ForEach-Object { $_.ipSecurityRestrictions.name }

$ruleName | Where-Object { $_ -ne "Deny all" } | ForEach-Object {
    Write-Host "Removendo regras: $_"
    az functionapp config access-restriction remove -g xxxxxxxxx -n xxxxxxxxx --rule-name $_
}
