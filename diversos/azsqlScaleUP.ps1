
$dbname = 'xxxxx'
$servername = 'xxxxx'
$ResourceGroupName = 'xxxxxx'
$edition = 'GeneralPurpose'
$Ncapacity = 1
$family = 'Gen5'
$size = '250GB'


$teste = az sql db show --name $dbname --resource-group $ResourceGroupName --server $servername -o json | ConvertFrom-Json
$capacity = $teste.currentSku.capacity


if ($capacity -eq $Ncapacity) {
    Write-Host "Ambiente escalado de forma correta, Vcores: $capacity"
} else {
    Write-Host "Escalando ambiente para Vcores: $Ncapacity"
    az sql db update -g $ResourceGroupName -n $dbname -s $servername --edition $edition --capacity $Ncapacity --family $family --max-size $size
}

#az sql db update -g $ResourceGroupName -n $dbname -s $servername --edition $edition --capacity $capacity --family $family --max-size $size