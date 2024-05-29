az devops login
#token:
$azuredevops = Get-AutomationVariable -Name $tkazuredevops
echo  $azuredevops | az devops login


$teste = az devops user show --user 'xxxxxxxxxxxxxx' -o json | ConvertFrom-json
$teste = az devops user list --top 500 -o json | ConvertFrom-json
$teste.user.principalName 
$teste.accessLevel.accountLicenseType
$teste.lastAccessedDate
$dataLicenca = [DateTime]::Parse($teste.lastAccessedDate)
$diferencaDias = (G$dataatual - $dataLicenca).Days


$teste = az devops user list --top 500 -o json | ConvertFrom-json
$usuariosComMaisDe60Dias = @()
$nenhumUsuarioEncontrado = $true

$teste.items | ForEach-Object {
    $usuario = $_.user.principalName
    $tipodeconta = $_.accessLevel.accountLicenseType
    $accesso = $_.lastAccessedDate
    $hoje = Get-Date
    $dataLicenca = [DateTime]::Parse($accesso)
    $diferencaDias = ($hoje - $dataLicenca).Days
    
    foreach ($diferent in $diferencaDias) {
        if ($diferent -gt 45 -and $tipodeconta -ne 'stakeholder') {
            $usuariosComMaisDe60Dias += $usuario
            $nenhumUsuarioEncontrado = $false
            
        }
    }
}
if ($nenhumUsuarioEncontrado) {
    Write-Output "Não há usuário maior que 60 dias sem utilizar o Azure DevOps."
} else {
    Write-Output "Lista de usuários com mais de 60 dias sem acessar o Azure DevOps:" $usuariosComMaisDe60Dias
    $numeroDeUsuarios = $usuariosComMaisDe60Dias.Count
    Write-Output "Total de usuários: $numeroDeUsuarios"
}



$dataLicenca = [DateTime]::ParseExact($teste.items.lastAccessedDate, "yyyy-MM-ddTHH:mm:ss.fffffffK", [System.Globalization.CultureInfo]::InvariantCulture)

$dataLicenca = [DateTime]::Parse($teste.lastAccessedDate)

$diferencaDias = ($dataAtual - $dataLicenca).Days






$usuario = Get-AzADUser -AppendSelected -userPrincipalName 'xxxxxxxxx' -Select 'AccountEnabled' | Select-Object Mail, AccountEnabled

$usuarioGet = Get-AzADUser -Filter 'AccountEnabled -eq $false'


