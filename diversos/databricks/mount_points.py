# Databricks notebook source
display(dbutils.fs.mounts())

# COMMAND ----------

#MOUNTPOINT

Escopo='<Escopo do Mount>'

configs = {"fs.azure.account.auth.type": "OAuth",
           "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
           "fs.azure.account.oauth2.client.id": dbutils.secrets.get(scope = '<scopeSecret>',key='<secretdoKeyvault>'),
           "fs.azure.account.oauth2.client.secret": dbutils.secrets.get(scope = '<scopeSecret>',key='<secretdoKeyvault>'),
           "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/72b5f416-8f41-4c88-a6a0-bb4b91383888/oauth2/token"}

ponto="/mnt/" + Escopo + "/dev/"
#dbutils.fs.unmount(ponto)
dbutils.fs.mount(
  source = "abfss://data@<<storage>>.dfs.core.windows.net/",
  mount_point = ponto,
  extra_configs = configs)