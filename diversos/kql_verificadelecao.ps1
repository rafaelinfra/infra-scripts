resourcechanges 
| extend changeTime = todatetime(properties.changeAttributes.timestamp), 
         targetResourceId = tostring(properties.targetResourceId), 
         operation = tostring(properties.changeAttributes.operation), 
         changeType = tostring(properties.changeType), 
         changedBy = tostring(properties.changeAttributes.changedBy), 
         changedByType = properties.changeAttributes.changedByType, 
         clientType = tostring(properties.changeAttributes.clientType) 
| project changeTime, changeType, changedBy, changedByType, clientType, 
operation_v2 = split(operation, "/")[array_length(split(operation, "/")) - 1], 
resource_v2 = split(targetResourceId, "/")[array_length(split(targetResourceId, "/")) - 1]
| order by changeTime desc