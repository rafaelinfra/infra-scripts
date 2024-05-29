$teste = az ad app list --filter "startswith(displayName, 'xxxxxxx')" -o json | ConvertFrom-Json

$credenciaisExpirando30Dias = @()
$hoje = Get-Date


foreach ($item in $teste) {
    $displayName = $item.displayName
    $passwordCredentials = $item.passwordCredentials
    #$SecretName = $item.passwordCredentials.displayName

    
    foreach ($credencial in $passwordCredentials) {
        $dataExpiracao = $credencial.endDateTime
        $SecretName = $credencial.displayName
        
        $diferencaDias = ($dataExpiracao - $hoje).Days
        #Write-Output $diferencaDias
        
        
        foreach ($dif in $diferencaDias){
            if ($dif -lt 15) {
                Write-Output $displayName
               
                $credenciaisExpirando30Dias += [PSCustomObject]@{
                    AppName = $displayName
                    SecretName = $SecretName
                    DataExpiracao = $dataExpiracao
                }
            } 
        }
    }
}

# resultados
$credenciaisExpirando30Dias


$credenciaisExpirando15Dias >> $tempFilePath

