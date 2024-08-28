# Databricks notebook source
import requests
import json
# from azure.identity import DefaultAzureCredential
# from azure.keyvault.secrets import SecretClient

# # Configuração do Key Vault
# key_vault_url = "<XXXXXXXXXXXX>"
# secret_name = "<XXXXXXXXXXXX>"

# # Autenticação e recuperação do token
# credential = DefaultAzureCredential()
# client = SecretClient(vault_url=key_vault_url, credential=credential)
# retrieved_secret = client.get_secret(secret_name)
token = '<incluirTokenDatabricks>'

# Defina os detalhes do Databricks e o token de acesso
DATABRICKS_INSTANCE = '<XXXXXXXXXXXX>'
TOKEN = f'Bearer {token}'

# Lista de emails dos novos usuários
users_emails = [
    "teste@teste.com",
    "teste1@teste.com",
    "teste2@teste.com",
]

group_name = "<XXXXXXXXXXXX>"  # Nome do grupo interno que você deseja adicionar os usuários

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

