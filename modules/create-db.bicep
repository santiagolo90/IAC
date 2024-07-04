targetScope = 'resourceGroup'

@description('Nombre del servidor MySQL')
param serverName string

@description('Ubicación del servidor MySQL')
param location string = resourceGroup().location

@description('Nombre del administrador')
param administratorLogin string

@description('Contraseña del administrador')
@secure()
param administratorLoginPassword string

@description('Versión de MySQL')
param version string = '5.7'  // Ajustado a una versión compatible

@description('SKU del servidor MySQL')
param skuName string = 'Standard_B1ms'  // SKU más comúnmente soportado

@description('Tamaño máximo del almacenamiento en GB')
param storageGB int = 32

@description('Nombre de la base de datos')
param databaseName string = 'db'

resource mysqlFlexibleServer 'Microsoft.DBforMySQL/flexibleServers@2022-01-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: version
    sslEnforcement: 'Enabled'
    storage: {
      storageSizeGB: storageGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource mysqlDatabase 'Microsoft.DBforMySQL/flexibleServers/databases@2022-01-01' = {
  parent: mysqlFlexibleServer
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
  dependsOn: [mysqlFlexibleServer]
}

resource allowAllIpsRule 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2022-01-01' = {
  parent: mysqlFlexibleServer
  name: 'AllowAllIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

output serverNameOutput string = mysqlFlexibleServer.name
output serverAdminLogin string = mysqlFlexibleServer.properties.administratorLogin
output serverFullyQualifiedDomainName string = mysqlFlexibleServer.properties.fullyQualifiedDomainName
