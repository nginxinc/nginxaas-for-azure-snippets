@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of all the resources for n4a')
param name string

@description('SKU of NGINX Deployment')
param sku string = 'preview_Monthly_gmz7xq9ge3py'

@description('dnslabel to give publicip')
param publiciplabel string = name

@description('IP of workload to proxy to')
param upstreams string = '#nginxcomment'

@description('Id of an existing subnet to deploy onto')
param existingSubnetId string = ''

param vnetName string = name

@description('Details of vnet to create')
param vnetAddress string = '172.25.1.0/24'
param vnetPeerWithVnet string = ''

@description('Enable publishing metrics data from NGINX deployment')
param enableMetrics bool = true

param rootpath string = '/etc/nginx/nginx.conf'

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-04-01' = if (!empty(vnetAddress)) {
  name: name
  location: location
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
          ]
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          priority: 100
        }
      }
    ]
  }
}

var peerwithid = (empty(vnetPeerWithVnet)) ? '' : resourceId('Microsoft.Network/virtualNetworks', vnetPeerWithVnet)
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = if (!empty(vnetAddress)) {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
    subnets: [
      {
        name: 'n4a'
        properties: {
          addressPrefix: vnetAddress
          networkSecurityGroup: {
            id: nsg.id
          }
          delegations: []
        }
      }
    ]
  }
  resource peerWithMain 'virtualNetworkPeerings' = if (!empty(vnetPeerWithVnet)) {
    name: 'peerWithMain'
    properties: {
      allowForwardedTraffic: true
      allowVirtualNetworkAccess: true
      remoteVirtualNetwork: {
        id: peerwithid
      }
    }
  }
}

// resource reversePeerWithMain 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = if (!empty(vnetPeerWithVnet)) {
//   name: '${vnetPeerWithVnet}/peerWith${vnet.name}'
//   properties: {
//     allowForwardedTraffic: true
//     allowVirtualNetworkAccess: true
//     remoteVirtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

resource pip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {}
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: publiciplabel
    }
    ipTags: []
  }
}
//var fqdn = reference(pip.id, '2020-08-01').dnsSettings.fqdn
var fqdn = pip.properties.dnsSettings.fqdn

var subnetid = existingSubnetId != '' ? existingSubnetId : vnet.properties.subnets[0].id

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
}
var principalId = reference(managedIdentity.id, '2018-11-30').principalId

resource n4a 'NGINX.NGINXPLUS/nginxDeployments@2021-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  sku: {
    name: sku
  }
  properties: {
    networkProfile: {
      frontEndIPConfiguration: {
        publicIPAddresses: [
          {
            id: pip.id
          }
        ]
        privateIPAddresses: []
      }
      networkInterfaceConfiguration: {
        subnetId: subnetid
      }
    }
    enableDiagnosticsSupport: enableMetrics
  }
}

resource MonitoringMetricsPublisher 'Microsoft.Authorization/roleAssignments@2018-09-01-preview' = if (enableMetrics) {
  scope: n4a
  name: guid(n4a.id, name, 'MonitoringMetricsPublisher')
  properties: {
    // Monitoring Metrics Publisher
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

var configTmpl = '''
http {{
  upstream app-1 {{
    zone app-1 64k;
    least_conn;
{0}
  }}

  server {{
    listen 80 default_server;
    server_name {1};

    location / {{
            default_type text/html;
            return 200 '<!DOCTYPE html><h2>Welcome to Azure!</h2>\n';
    }}

    location /app {{
      proxy_pass http://app-1/;
    }}
  }}
}}
'''

resource config 'NGINX.NGINXPLUS/nginxDeployments/configurations@2021-05-01-preview' = {
  parent: n4a
  name: 'default'
  location: location
  properties: {
    rootFile: rootpath
    files: [
      {
        content: base64(format(configTmpl, upstreams, fqdn))
        virtualPath: rootpath
      }
    ]
  }
}

output fqdn string = fqdn
output http string = 'http://${fqdn}/'
output vnetid string = vnet.id
