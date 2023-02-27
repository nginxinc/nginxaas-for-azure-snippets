@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of your NGINX deployment resource')
param nginxDeploymentName string = 'myDeployment'

@description('SKU of NGINX deployment')
param sku string = 'standard_Monthly'

@description('Name of public IP')
param publicIPName string = 'myPublicIP'

@description('Name of public subnet')
param subnetName string

@description('The name of the user-assigned managed identity associated to the NGINX deployment resource')
param userAssignedIdentityName string

@description('Name of customer virtual network')
param virtualNetworkName string

@description('Enable publishing metrics data from NGINX deployment')
param enableMetrics bool = false

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    ipTags: []
  }
}

resource deployment 'NGINX.NGINXPLUS/nginxDeployments@2021-05-01-preview' = {
  name: nginxDeploymentName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentityName)}': {
      }
    }
  }
  properties: {
    enableDiagnosticsSupport: enableMetrics
    networkProfile: {
      frontEndIPConfiguration: {
        publicIPAddresses: [
          {
            id: publicIP.id
          }
        ]
        privateIPAddresses: []
      }
      networkInterfaceConfiguration: {
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
      }
    }
  }
}
