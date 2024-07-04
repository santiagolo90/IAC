targetScope = 'resourceGroup'

param name string = 'acr${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param skuName string = 'Basic'

param tags object

resource iacTemplateContainerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}

@description('Output the login server property for later use')
output loginServer string = iacTemplateContainerRegistry.properties.loginServer
output name string = iacTemplateContainerRegistry.name
output username string = iacTemplateContainerRegistry.listCredentials().username
output password string = iacTemplateContainerRegistry.listCredentials().passwords[0].value
