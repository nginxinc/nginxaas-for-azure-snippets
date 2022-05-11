var workloadlocation = 'westcentralus'
var NATSubnetName = 'plsnat'

param identityname string = 'n4ami'

resource allowall 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: 'nsg'
  location: workloadlocation
  properties: {
    securityRules: [
      {
        name: 'allow'
        properties: {
          protocol: 'Tcp'
          direction: 'Inbound'
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '80'
            '22'
          ]
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          priority: 100
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-04-01' = {
  name: 'vnet'
  location: workloadlocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.24.0.0/16'
      ]
    }
    subnets: [
      {
        name: NATSubnetName
        properties: {
          addressPrefix: '172.24.0.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'workload'
        properties: {
          addressPrefix: '172.24.1.0/24'
          networkSecurityGroup: {
            id: allowall.id
          }
        }
      }
    ]
  }
}

// module pls 'pls.bicep' = {
//   name: 'pls'
//   params: {
//     location: workloadlocation
//     name: 'njbmtpls'
//     subnetid: '${vnet.id}/subnets/${NATSubnetName}'
//   }
// }

module wombat 'workload.bicep' = {
  name: 'wombat'
  params: {
    name: 'wombat'
    workloadlocation: workloadlocation
    subnetid: '${vnet.id}/subnets/workload'
    //backendPoolId: pls.outputs.backendPoolId
  }
}

module wizard 'workload.bicep' = {
  name: 'wizard'
  params: {
    name: 'wizard'
    workloadlocation: workloadlocation
    subnetid: '${vnet.id}/subnets/workload'
    //backendPoolId: pls.outputs.backendPoolId
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityname
  location: workloadlocation
}

module n1 'nalb.bicep' = {
  name: 'n1'
  params: {
    location: workloadlocation
    workloadIP: 'server http://${wombat.outputs.ip};\nserver http://${wizard.outputs.ip};\n'
    managedIdentityId: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', identityname)
    vnetName: 'njbmtn1'
    vnetAddress: '172.25.1.0/24'
    vnetPeerWithId: vnet.id
    publicIPName: 'njbmtn1'
    nginxDeploymentName: 'njbmtn1'
    nsgId: allowall.id
  }
}
