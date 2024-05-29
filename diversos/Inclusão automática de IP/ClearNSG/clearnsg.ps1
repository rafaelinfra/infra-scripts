#variáveis
$NSGname = "vm-tester-nsg"
$RGname = "RG-TESTES"

#Informações do NSG especificado
$NSG = Get-AzNetworkSecurityGroup -Name $NSGname -ResourceGroupName $RGname

#Lista com as regra existentes, excluindo regras padrão, que são criadas pelo AZURE
$InboundRules = $NSG.SecurityRules | Where-Object { $_.Direction -eq "Inbound" }

#Loop para cada uma das regras existentes, é guardado dentro de $NSG a etapa de remoção
foreach ($rule in $InboundRules) {
    $ruleName = $rule.Name

    if ($ruleName -ne "DenyAll") {
        Write-Host "Removendo a regra: $ruleName"
        $NSG | Remove-AzNetworkSecurityRuleConfig -Name $ruleName
    }
}
# Reconfigura o NSG com as exclusões
$NSG | Set-AzNetworkSecurityGroup