@description('a prefix to put on all publicip dns labels to make it more unique')
param publicipprefix string = resourceGroup().name

param mainLocation string = 'eastus2'
param altLocation string = 'westcentralus'

resource allowall 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: 'workload-allowall'
  location: mainLocation
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
  name: 'mainvnet'
  location: mainLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.32.0/19'
      ]
    }
    subnets: [
      {
        name: 'workload'
        properties: {
          addressPrefix: '192.168.32.0/24'
          networkSecurityGroup: {
            id: allowall.id
          }
        }
      }
      {
        name: 'n4a'
        properties: {
          addressPrefix: '192.168.33.0/24'
          networkSecurityGroup: {
            id: allowall.id
          }
        }
      }
    ]
  }
}

resource akv 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: '${publicipprefix}-akv'
  location: mainLocation

  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 7
  }
}

module wombat 'workload.bicep' = {
  name: 'wombat'
  params: {
    name: 'wombat'
    workloadlocation: mainLocation
    subnetid: '${vnet.id}/subnets/workload'
    //publiciplabel: '${publicipprefix}-wombat'
  }
}

module wizard 'workload.bicep' = {
  name: 'wizard'
  params: {
    name: 'wizard'
    workloadlocation: mainLocation
    subnetid: '${vnet.id}/subnets/workload'
    //publiciplabel: '${publicipprefix}-wizard'
  }
}

// this can't be a multiline string becuase then variables aren't interpolated
var upstreamservers = 'server ${wombat.outputs.ip};\nserver ${wizard.outputs.ip};'

module n1 'n4a.bicep' = {
  name: 'n1'
  params: {
    name: 'n4ademo'
    location: altLocation
    upstreams: upstreamservers

    vnetAddress: '172.25.1.0/24'
    vnetPeerWithId: vnet.id
    publiciplabel: '${publicipprefix}-n4ademo'
  }
}

resource n1peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  parent: vnet
  name: 'peerWith${n1.name}'
  properties: {
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: n1.outputs.vnetid
    }
  }
}

output n4ademofqdn string = n1.outputs.fqdn
output akvname string = akv.name
