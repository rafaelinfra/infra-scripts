#az extension add --name azure-devops --allow-preview true
#205
echo  'xxxxxxxxxxxxxxxxxxx' | az devops login --org https://dev.azure.com/xxxxxxxxxxxx
$condicao = $true
$temporizador = 0

#InProgress
$Limite = 0
while($condicao){

    $definition = az pipelines runs list --project prj-pco --pipeline-ids 203 --top 1 --query-order StartTimeDesc -o json | ConvertFrom-Json
#    $Status = $definition.status
    $Status = 'InProgress'
    $Result = $definition.result
    if( ($Status -eq 'InProgress') -and ($Temporizador -le $Limite) -and ($Result -ne 'failed')){
        $Temporizador +=3
        $condicao = $true
        Write-Output "Aguardando 5 min para nova conferencia de status... Status atual: $Status"
        Start-Sleep -Seconds 10
    }
    elseif (($Status -eq 'completed') -and ($Result -ne 'failed')) {
        Write-Output "Status da esteira: $Status"
        $condicao = $false
    }else{

        $baseuri = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
        $header = @{
            "Accept" = "text/json"
            "Content-Type" = "application/json"
        }
        
        Write-Output "Verificando o Webhook do Microsoft Teams ......."
        Start-Sleep -Seconds 2
        Write-Output "Iniciando envio de Card"
        $uri_login = $baseuri
        $body = '{
            "type": "message",
            "attachments": [
              {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "content": {
                  "type": "AdaptiveCard",
                  "body": [
                    {
                      "type": "TextBlock",
                      "size": "Medium",
                      "weight": "Bolder",
                      "text": "Sample Adaptive Card with User Mention"
                    },
                    {
                      "type": "TextBlock",
                      "text": "Hi <at>Manoel</at>, <at>Rafael</at>, xxxxxxxxxxxx "
                    }
                  ],
                  "actions": [
                    {
                      "type": "Action.OpenUrl",
                      "title": "ConfiraComigoNoReplay",
                      "url": "xxxxxxxxxxxxxxx"
                    }
                  ],
                  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                  "version": "1.0",
                  "msteams": {
                    "entities": [
                      {
                        "type": "mention",
                        "text": "<at>Manoel</at>",
                        "mentioned": {
                          "id": "xxxxxxxxxxx",
                          "name": "Manoel"
                        }
                      },
                      {
                        "type": "mention",
                        "text": "<at>Rafael</at>",
                        "mentioned": {
                          "id": "xxxxxxxxxxxxx",
                          "name": "Rafael"
                        }
                      }
                    ]
                  }
                }
              }
            ]
          }'
        Invoke-RestMethod -Method Post $uri_login -Headers $header -Body $body
        Start-Sleep -Seconds 2
        Write-Output "Card enviado com sucesso"


        Write-Output "Status da Esteira: $Status"
        $condicao = $false
    }
        
}
