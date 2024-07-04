@description('Nombre del Network Security Group')
param nsgName string

@description('Ubicación del recurso')
param location string

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnyCustom8080Inbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyHTTPInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyHTTPSInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
        }
      }

      {
        name: 'AllowAnyCustom3000Inbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3000'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 160
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgId string = nsg.id
