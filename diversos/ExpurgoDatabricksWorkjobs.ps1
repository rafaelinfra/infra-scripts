### Instala a cli do databricks ###
pip install --upgrade pip
pip install databricks-cli

### Configura acli do databricks ###
####################################

### Id do recurso Databricks ###
$resourceId="xxxxxxx"

# Variaveis
$PIPdtbWorkspaceName="xxxxx"
$PIPresourceGroupName="xxxxxxxxxxxx"

Write-Host "Variavel Workspace: $PIPdtbWorkspaceName"
Write-Host "Variavel ResourceGroup: $PIPresourceGroupName"
#Write-Host "Variavel Diretorio: $($env:SYSTEM_DEFAULTWORKINGDIRECTORY)"
#Write-Host "Variavel Diretorio: $($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS)"
#Write-Host "Variavel Assunto: $(PIPpastaAssunto)"
Write-Host "Variavel ResourceGrup: $resourceGroupName"
Write-Host "Variavel ResourceId: $resourceId"
#Write-Host "Variavel SPId: $env:servicePrincipalId"

### Obter a url do Workpscape Databricks ###
$dtbInfo=$(az resource show -g $PIPresourceGroupName -n $PIPdtbWorkspaceName --resource-type 'workspaces' --namespace 'Microsoft.Databricks')
$dtburl=($dtbInfo|ConvertFrom-Json).properties.workspaceUrl
$dbxurl="https://$dtburl"
#$dbxurl="https://adb-6941437225666776.16.azuredatabricks.net"

Write-Host "Variavel url DTB: $dbxurl"

### Obter o Token AAD para configurar a Cli do Databricks ###
$tokenJson=$(az account get-access-token --resource $resourceId)
$DATABRICKS_AAD_TOKEN=($tokenJson|ConvertFrom-Json).accessToken

#Write-Host "Variavel DATABRICKS_AAD_TOKEN: $DATABRICKS_AAD_TOKEN"
#Write-Host "##vso[task.setvariable variable=token]$DATABRICKS_AAD_TOKEN"
#Write-Host "##vso[task.setvariable variable=urlDtb]$($dbxurl.Split(".azuredatabricks.net")[0])"

### Configurar a cli do Databricks com o token e a url ###
databricks configure --aad-token --host $dbxurl

### Listar arquivos ocultos. validar criaçãoda configuracao .databrickscfg ###
#$arqCont=$(dir . -force | ? { $_.Attributes –band [IO.FileAttributes]::Hidden })
#$arqCont=$(dir . -force | ? )
#Write-Host "Dir: $arqCont"

Write-Host "Listar WorkJobs:"
#$workJobsList= $(databricks jobs list --output )
$workJobsList= $(databricks jobs list)
#$workJobsList= $(databricks jobs list --output json | jq '.jobs[] | select(.settings.name == "Untitled") | .job_id')
Write-Host "$workJobsList"