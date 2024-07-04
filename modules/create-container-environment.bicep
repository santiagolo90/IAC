@description('The app name.')
param appName string

@description('The name of the Container App environment.')
param environmentName string

@description('The location of the Container App environment.')
param location string = resourceGroup().location

@description('The tags of the Container App.')
param tags object
param LogAnalyticsClientId string
@secure()
param LogAnalyticsClientSecret string

//param subnetId string
//param internal bool = true


var loggingOptions = {
  destination: 'log-analytics'
  logAnalyticsConfiguration: {
    customerId: LogAnalyticsClientId
    sharedKey: LogAnalyticsClientSecret
  }
}

// ContainerEnvironmentModule
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: format('ace-{0}-{1}-001', appName, environmentName)
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: loggingOptions
    // vnetConfiguration: {
    //   internal: internal
    //   infrastructureSubnetId: subnetId
    // }
    zoneRedundant: false
  }
}

output id string = containerAppEnv.id
output defaultDomain string = containerAppEnv.properties.defaultDomain
output staticIp string = containerAppEnv.properties.staticIp
