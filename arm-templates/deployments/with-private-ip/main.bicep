@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of your NGINX deployment resource')
param nginxDeploymentName string = 'myDeployment'

@description('SKU of NGINX deployment')
param sku string = 'standardv3_Monthly'

@description('Private IP address located on subnet delegated to NGINX deployment')
param privateIPAddress string

@description('Name of private subnet')
param subnetName string

@description('Name of customer virtual network')
param virtualNetworkName string

@description('Capacity in NCUs to assign the NGINX deployment')
param capacity int = 50

resource deployment 'NGINX.NGINXPLUS/nginxDeployments@2023-09-01' = {
  name: nginxDeploymentName
  location: location
  sku: {
    name: sku
  }
  properties: {
    networkProfile: {
      frontEndIPConfiguration: {
        privateIPAddresses: [
          {
            subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
            privateIPAllocationMethod: 'Static'
            privateIPAddress: privateIPAddress
          }
        ]
        publicIPAddresses: []
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
