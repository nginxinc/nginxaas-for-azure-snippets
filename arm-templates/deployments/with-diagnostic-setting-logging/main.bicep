@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of your NGINX deployment resource')
param nginxDeploymentName string = 'myDeployment'

@description('SKU of NGINX deployment')
param sku string = 'standardv2_Monthly'

@description('Name of public IP')
param publicIPName string = 'myPublicIP'

@description('Name of public subnet')
param subnetName string

@description('Name of customer virtual network')
param virtualNetworkName string

@description('Capacity in NCUs to assign the NGINX deployment')
param capacity int = 50

@description('Name of your diagnostic setting to create for deployment logs')
param diagnosticSettingName string = 'myDiagnosticSetting'

@description('Resource ID of the storage account to publish diagnostic setting logs')
param diagnosticSettingStorageAccountID string

resource nginxDeploymentName_resource 'NGINX.NGINXPLUS/nginxDeployments@2023-09-01' = {
  name: nginxDeploymentName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    networkProfile: {
      frontEndIPConfiguration: {
        publicIPAddresses: [
          {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIPName)
          }
        ]
        privateIPAddresses: []
      }
      networkInterfaceConfiguration: {
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
      }
    }
    scalingProperties: {
      capacity: capacity
    }
  }
}

resource nginxDeploymentName_Microsoft_Insights_diagnosticSettingName 'NGINX.NGINXPLUS/nginxDeployments/providers/diagnosticSettings@2025-03-01-preview' = {
  name: '${nginxDeploymentName}/Microsoft.Insights/${diagnosticSettingName}'
  properties: {
    storageAccountId: diagnosticSettingStorageAccountID
    logs: [
      {
        category: 'NginxLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 1
        }
      }
    ]
  }
}
