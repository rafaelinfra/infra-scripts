param (
    [string]$ruleName,
    [string]$myIp,
    [string]$priorityNumber
)

$rulePort = 2222
$ruleDesc = "Allow SSH"
$nsgNames = "vm-tester-nsg"

function AddOrUpdateRDPRecord {
    Process {
        $nsg = Get-AzNetworkSecurityGroup -Name $_
        $ruleExists = (Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg).Name.Contains($ruleName);

        if($ruleExists)
        {
            # Update the existing rule with the new IP address
            Set-AzNetworkSecurityRuleConfig `
                -Name $ruleName `
                -Description $ruleDesc `
                -Access Allow `
                -Protocol * `
                -Direction Inbound `
                -Priority $priorityNumber `
                -SourceAddressPrefix $myIp `
                -SourcePortRange * `
                -DestinationAddressPrefix * `
                -DestinationPortRange $rulePort `
                -NetworkSecurityGroup $nsg
        }
        else
        {
            # Create a new rule
            $nsg | Add-AzNetworkSecurityRuleConfig `
                -Name $ruleName `
                -Description $ruleDesc `
                -Access Allow `
                -Protocol * `
                -Direction Inbound `
                -Priority $priorityNumber `
                -SourceAddressPrefix $myIp `
                -SourcePortRange * `
                -DestinationAddressPrefix * `
                -DestinationPortRange $rulePort
        }

        # Save changes to the NSG
        $nsg | Set-AzNetworkSecurityGroup
    }
}

$nsgNames | AddOrUpdateRDPRecord