# Databricks notebook source
# MAGIC %md
# MAGIC - [Bibliotecas utilizadas](https://adb-6941437225666776.16.azuredatabricks.net#notebook/1711207685938741/command/3598337837477777)
# MAGIC
# MAGIC - [Informações necessárias para acesso ao cluster](https://adb-6941437225666776.16.azuredatabricks.net#notebook/1711207685938741/command/3598337837477782)
# MAGIC
# MAGIC - [Criação de Grupo](https://adb-6941437225666776.16.azuredatabricks.net#notebook/1711207685938741/command/3598337837477764)
# MAGIC
# MAGIC - [Adição de usuário ao databricks e inclusão em grupo existente](https://adb-6941437225666776.16.azuredatabricks.net#notebook/1711207685938741/command/3598337837477790)
# MAGIC
# MAGIC - [Adicição de usuário existente ao grupo](https://adb-6941437225666776.16.azuredatabricks.net#notebook/1711207685938741/command/3598337837477791)
# MAGIC
# MAGIC - [Criação de Cluster](https://adb-6941437225666776.16.azuredatabricks.net#notebook/1711207685938741/command/3598337837477796)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Bibliotecas necessárias

# COMMAND ----------

import requests
import json

# COMMAND ----------

# MAGIC %md
# MAGIC ## Informações para acesso ao databricks

# COMMAND ----------

token = 'xxxxxxx'

DATABRICKS_INSTANCE = 'https://xxxxx.azuredatabricks.net' 
TOKEN = f'Bearer {token}'

# COMMAND ----------

# MAGIC %md
# MAGIC > ## Criação de grupos

# COMMAND ----------

new_group_name = [ 
    "teste_rafael",
]

url_groups = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Groups"

headers = {
    'Authorization': TOKEN,
    'Content-Type': 'application/json'
}

group_add = []
for group_name in new_group_name:
    group_data = {
        "schemas": ["urn:ietf:params:scim:schemas:core:2.0:Group"],
        "displayName": group_name
    }
    group_add.append(group_data)

for group in group_add:
    response = requests.post(url_groups, headers=headers, data=json.dumps(group))
    if response.status_code == 201:
        print(f"Grupo {group['displayName']} criado com sucesso.")
    else:
        print(f"Falha ao criar grupo {group['displayName']}: {response.status_code}, {response.text}")


# COMMAND ----------

# MAGIC %md
# MAGIC > ## Adicionando usuários ao Databricks e incluindo eles em um grupo

# COMMAND ----------

users_emails = [
    "xxxxxxx@xxxxxx",
]

#Caso os usuários sejam colocados em outro grupo, o variável abaixo precisa ser alterada
group_name = "users"

# URL da API para adicionar usuário
url = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Users"

# Cabeçalhos
headers = {
    'Authorization': TOKEN,
    'Content-Type': 'application/json'
}

# Dados dos novos usuários
users_data = []
for email in users_emails:
    user_data = {
        "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
        "userName": email,
        "emails": [{"value": email, "primary": True}]
    }
    users_data.append(user_data)

# Adicionar cada usuário
for user_data in users_data:
    # Enviar solicitação para adicionar usuário
    response = requests.post(url, headers=headers, data=json.dumps(user_data))

    if response.status_code == 201:
        print(f"Usuário {user_data['userName']} adicionado com sucesso.")

        # Adicionar usuário ao grupo interno
        user_id = response.json().get("id")
        group_id = None

        # Buscar ID do grupo
        group_url = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Groups"
        group_response = requests.get(group_url, headers=headers)
        groups = group_response.json().get("Resources", [])

        for group in groups:
            if group.get("displayName") == group_name:
                group_id = group.get("id")
                break

        if group_id:
            # Adicionar usuário ao grupo
            group_member_url = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Groups/{group_id}"
            payload = {
                "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
                "Operations": [
                    {
                        "op": "add",
                        "path": "members",
                        "value": [
                            {
                                "value": user_id,
                                "display": user_data['userName']
                            }
                        ]
                    }
                ]
            }

            group_member_response = requests.patch(group_member_url, headers=headers, data=json.dumps(payload))

            if group_member_response.status_code == 200:
                print(f"Usuário {user_data['userName']} adicionado ao grupo {group_name}.")
            else:
                print(f"Falha ao adicionar usuário ao grupo: {group_member_response.status_code}, {group_member_response.text}")
        else:
            print(f"Grupo {group_name} não encontrado.")
    else:
        print(f"Falha ao adicionar usuário {user_data['userName']}: {response.status_code}, {response.text}")

# COMMAND ----------

# MAGIC %md
# MAGIC > ## Adicionando usuários existentes a um grupo existente

# COMMAND ----------

users_emails = [
    "xxxxxxxxx@xxxxxxx",
]

# nome do grupo existente
group_name = "users"

# Cabeçalhos
headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

# URL da API para obter a lista de grupos
group_url = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Groups"

# Buscar o ID do grupo
group_response = requests.get(group_url, headers=headers)
groups = group_response.json().get("Resources", [])

group_id = None
for group in groups:
    if group.get("displayName") == group_name:
        group_id = group.get("id")
        break

if not group_id:
    print(f"Grupo {group_name} não encontrado.")
else:
    print(f"Grupo encontrado: {group_name} (ID: {group_id})")

    # Adicionar cada usuário existente ao grupo
    for email in users_emails:
        # Buscar o ID do usuário com base no email
        user_url = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Users"
        user_response = requests.get(user_url, headers=headers)
        users = user_response.json().get("Resources", [])

        user_id = None
        for user in users:
            if user.get("userName") == email:
                user_id = user.get("id")
                break

        if not user_id:
            print(f"Usuário {email} não encontrado.")
        else:
            # Adicionar o usuário ao grupo
            group_member_url = f"{DATABRICKS_INSTANCE}/api/2.0/preview/scim/v2/Groups/{group_id}"
            payload = {
                "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
                "Operations": [
                    {
                        "op": "add",
                        "path": "members",
                        "value": [
                            {
                                "value": user_id
                            }
                        ]
                    }
                ]
            }

            group_member_response = requests.patch(group_member_url, headers=headers, data=json.dumps(payload))

            if group_member_response.status_code == 200:
                print(f"Usuário {email} adicionado ao grupo {group_name} com sucesso.")
            else:
                print(f"Falha ao adicionar usuário {email} ao grupo: {group_member_response.status_code}, {group_member_response.text}")


# COMMAND ----------

# MAGIC %md
# MAGIC > ## Criação de cluster
# MAGIC

# COMMAND ----------

## Nome do cluster
cl_name = "cluster-ipp-rafael"

## adicionar todas tags necessárias
tags = {
        "rafael": "teste",
}

url = f"{DATABRICKS_INSTANCE}/api/2.0/clusters/create"
headers = {
    'Authorization': TOKEN,
    'Content-Type': 'application/json'
}

# Configuração do cluster (personalize conforme necessário)
cluster_data = {
    "cluster_name": cl_name,
    "spark_version": "13.3.x-scala2.12",  # Versão do Spark
    "node_type_id": "Standard_DS3_v2",    # Tipo de nó de trabalho
    "autoscale": {
        "min_workers": 1,                 # Número mínimo de nós
        "max_workers": 1                  # Número máximo de nós
    },
    "autotermination_minutes": 20,         # Cluster será encerrado após xxx minutos de inatividade
    "driver_node_type_id": "Standard_DS3_v2",  # Tipo de nó do driver
    "azure_attributes": {
        "first_on_demand": 1,
        "availability": "SPOT_WITH_FALLBACK_AZURE",
        "spot_bid_max_price": -1
    },
    "custom_tags": tags,
    "spark_env_vars": {
        "PYSPARK_PYTHON": "/databricks/python3/bin/python3"
    },
    "spark_conf": {},
    "data_security_mode": "NONE",
    "runtime_engine": "STANDARD",       ## configuração para Cluster não isolado
    "effective_spark_version": "13.3.x-scala2.12",
}

response = requests.post(url, headers=headers, data=json.dumps(cluster_data))

if response.status_code == 200:
    print(f"Cluster criado com sucesso. ID do cluster: {response.json().get('cluster_id')}")
else:
    print(f"Falha ao criar cluster: {response.status_code}, {response.text}")
