#BUSCANDO IP'S PÚBLICOS DO AZURE.

#Buscando o Json da documentação do AZURE

$pageUrl = "https://www.microsoft.com/en-us/download/details.aspx?id=56519"
$pageContent = Invoke-WebRequest -Uri $pageUrl

#expressão para buscar apenas o que esta entre "File Name:" (Esse campo se refere ao .json de atualização do AZURE relacionado aos Ips)
$regex = "File Name:</h3><p.*?>(\S+)</p>"

#aplica a expressão
$match = $pageContent.Content -match $regex

#Caso essa expressão acima traga False como valor, o processo abaixo não rodará

#verifica se encontrou o valor de File Name
if ($match) {
    $fileName = $Matches[1]
    Write-Host "O valor de File Name é $fileName"
}
else {
    Write-Host "Não foi possível encontrar o valor de File Name"
}

#busca o .json atualizado com os Ip's atualizados
$ipRangesJson = Invoke-RestMethod -Uri "https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/$filename" 

#Separando por recurso e guardando em uma lista os ip IPV4 e IPV6
#Coloquei uma variável abaixo onde você deve determinar o recurso.região
$RR = "DataFactory.EastUS2"
$azureCloudIpRanges = $ipRangesJson.values | Where-Object { $_.name -eq $RR } | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty addressPrefixes


#salvando em uma nova lista apenas os ipv4
#Caso a intenção seja utilizar ipv6, não precisa executar o comando abaixo a variável resposta será $azurecloudIpRanges
$validIpv4Ranges = $azureCloudIpRanges | Where-Object { $_ -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" }

#mostrando a lista
$validIpv4Ranges