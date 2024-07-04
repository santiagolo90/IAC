# Infraestructura como código (IAC)

Proyecto para implementar recursos de Azure basado en plantillas Bicep.

## Ejemplo con plantilla main.bicep

### Pre deployment comando `what-if`

Run `az deployment sub what-if --name IacTemplateDeployment --location westeurope --template-file main.bicep --parameters main.bicepparam`

### Deployment comando `create`

Run `az deployment sub create --name IacTemplateDeployment --location westeurope --template-file main.bicep --parameters main.bicepparam`