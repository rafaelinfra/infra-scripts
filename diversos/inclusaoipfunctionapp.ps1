param (
    [string]$ruleName,
    [string]$myIp,
    [string]$priorityNumber
)

az functionapp config access-restriction add -g rg-ipp-sandbox `
    -n func-ipp-sandbox `
    --rule-name $ruleName `
    --action Allow `
    --ip-address $myIp/32 `
    --priority $priorityNumber