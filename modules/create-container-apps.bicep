@description('The name of the Container App.')
param name string

@description('The location of the Container App.')
param location string = resourceGroup().location

@description('The tags of the Container App.')
param tags object

@description('The container image to deploy.')
param containerImage string

@description('The container port to expose.')
param containerPort int = 8080

@description('The CPU to allocate to the container.')
param cpu string = '0.25'

@description('The memory to allocate to the container.')
param memory string = '0.5'

@description('The ace id.')
param containerAppEnvID string
param registryName string
@secure()
param acrPassword string
param appSettings array = []
param scaleRules object = {
  maxReplicas: 5
  minReplicas: 0
}

var helloworldImage = 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnvID
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        allowInsecure: false
        external: true
        targetPort: containerPort
        transport: 'Auto'
      }
      secrets: [
        {
          name: 'containerregistrypasswordref'
          value: acrPassword
        }
      ]
      registries: [
        {
          server: '${registryName}.azurecr.io'
          username: registryName
          passwordSecretRef: 'containerregistrypasswordref'

        }
      ]
    }
    template: {
      containers: [
        {
          name: name
          image: helloworldImage
          env: appSettings
          resources: {
            cpu: json('${cpu}')
            memory: '${memory}Gi'
          }
        }
      ]
      scale: scaleRules
    }
  }
}

output containerAppId string = containerApp.id
