@description('The app name.')
param appName string

@description('The name of the Container App environment.')
param environmentName string
param location string
param tags object
param dailyQuotaGb string = '0.025'

resource LogAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: format('Log-analytics-{0}-{1}-001', appName, environmentName)
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
      
    }
    workspaceCapping: {
      dailyQuotaGb: json(dailyQuotaGb)}

    sku: {
      name: 'PerGB2018'
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  })
}
output clientId string = LogAnalytics.properties.customerId
output clientSecret string = LogAnalytics.listKeys().primarySharedKey
output workspaceResourceId string = LogAnalytics.id
