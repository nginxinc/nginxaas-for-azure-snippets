@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the network security group')
param networkSecurityGroupName string

@description('Name of public IP')
param publicIPName string = 'myPublicIP'

@description('Name of virtual network')
param virtualNetworkName string = 'myVnet'

@description('Address prefix to use for virtual network')
param virtualNetworkAddressPrefix string

@description('Name of subnet to create in virtual network')
param subnetName string = 'mySubnet'

@description('Address prefix to use for subnet')
param subnetAddressPrefix string

resource publicIP 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: publicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  location: location
  name: networkSecurityGroupName
  properties: {
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          delegations: [
            {
              name: 'NGINX.NGINXPLUS/nginxDeployments'
              properties: {
                serviceName: 'NGINX.NGINXPLUS/nginxDeployments'
              }
            }
          ]
        }
      }
    ]
  }
}
