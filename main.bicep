targetScope = 'subscription'

param appName string = 'iac-template'
@allowed(['dev', 'test', 'qa', 'stage','pre', 'prod'])
param environmentName string = 'dev'
param location string = 'westeurope'

var moduleNameFormatString = toLower('{0}-${appName}-${environmentName}-module')
var resourceNameFormatString = toLower('{0}-${appName}-${environmentName}')
var criticalTagValue = {
  dev: 'Low'
  test: 'Low'
  qa: 'Medium'
  pre: 'High'
  stage: 'High'
  prod: 'Mission-critical'
}

var tags = {
  WorkloadName: ''
  DataClassification: 'Restricted'
  Criticality: criticalTagValue[environmentName]
  BusinessUnit: 'USER TECH'
  OpsCommitment: 'Platform operations'
  OpsTeam: 'USER TECH'
  Env: toUpper(environmentName)
  Owner: 'USER TECH'
  ApplicationName: toUpper(appName)
}


/* Resource Groups */

resource ResourceGroups 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: format('rg-{0}-docker-{1}-001', appName, environmentName)
  location: location
  tags: tags
}

/* Container Registry */

 module ContainerRegistry 'modules/create-container-registry.bicep' = {
   name: format(moduleNameFormatString, 'cr')
   scope: ResourceGroups
   params: {
     name: '${replace(format(resourceNameFormatString, 'cr'), '-', '')}001'
     location: location
     tags: tags
   }
 }

 //Network Security Group
module NetworkSecurityGroup 'modules/create-nsg.bicep' = {
  name: format(resourceNameFormatString, 'nsg')
  scope: ResourceGroups
  params: {
    nsgName: format(resourceNameFormatString, 'nsg')
    location: location
  }
}

// Log Analytics Container
module LogAnalyticsContainer 'modules/create-log-analytics.bicep' = {
  name: 'LogAnalyticsContainer'
  scope: ResourceGroups
  params: {
    location: location
    tags: tags
    appName: appName
    environmentName: environmentName
  }
}

/* Container Enviroment */
module ContainerEnviroment 'modules/create-container-environment.bicep' = {
  name: format(moduleNameFormatString, 'ace')
  scope: ResourceGroups
  params: {
    appName: appName
    environmentName: environmentName
    tags: tags
    location: location
    LogAnalyticsClientId: LogAnalyticsContainer.outputs.clientId
    LogAnalyticsClientSecret: LogAnalyticsContainer.outputs.clientSecret
  }
}


  /* MySql */
module MySql 'modules/create-db.bicep' = {
  name: format(moduleNameFormatString, 'mysql')
  scope: ResourceGroups
  params: {
    serverName: format(resourceNameFormatString, 'mysql')
    location: location
    administratorLogin: 'user'
    administratorLoginPassword: 'password'
  }
}
/* Container Apps */

// Array con la info de las apps
var appsInfo = [
  {
    name: 'front'
    repository: 'fronttemplate'
    cpu: '0.5'
    memory: '1'
    port: 80
  }
  {
    name: 'nestjs'
    repository: 'nestjstemplate'
    cpu: '0.5'
    memory: '1'
    port: 3000
    healthCheckUrl: '/health'
    readyCheckUrl: '/health/ready'
  }
  {
    name: 'dotnet'
    repository: 'dotnettemplate'
    cpu: '0.5'
    memory: '1'
    port: 8080
    healthCheckUrl: '/health/ready'
    readyCheckUrl: '/health/ready'
  }
]

var aspNetEnvironment = (environmentName == 'dev'
  ? 'Development'
  : environmentName == 'qa' ? 'QA' : environmentName == 'pre' ? 'Pre' : 'Pro')

  //Container Apps
  module ContainerAppsFrontAndBacks 'modules/create-container-apps.bicep' = [
  for app in appsInfo: {
    name: format('aca-{0}-{1}-001', app.name, environmentName)
    scope: ResourceGroups
    params: {
      name: format('aca-{0}-{1}-001', app.name, environmentName)
      location: location
      tags: tags
      containerImage:app.repository
      containerPort: app.port
      cpu: app.cpu
      memory: app.memory
      containerAppEnvID: ContainerEnviroment.outputs.id
      registryName: ContainerRegistry.outputs.name
      acrPassword: ContainerRegistry.outputs.password
      appSettings: concat(
        [
          {
            name: 'ASPNETCORE_ENVIRONMENT'
            value: aspNetEnvironment
          }
        ]
      )
      
    }
  }
]
