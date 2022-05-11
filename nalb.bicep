@description('Location for all resources')
param location string

@description('Name of your NGINX deployment resource')
param nginxDeploymentName string

@description('SKU of NGINX Deployment')
param sku string = 'preview_Monthly_hjdtn7tfnxcy'

@description('The name of the user-assigned managed identity associated to the NGINX deployment resource')
param managedIdentityId string

@description('Name of public IP')
param publicIPName string

@description('IP of workload to proxy to')
param workloadIP string

@description('Name of customer virtual network')
param vnetName string
param vnetAddress string
param vnetPeerWithId string
param nsgId string

@description('Enable publishing metrics data from NGINX deployment')
param enableMetrics bool = true

resource pip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {}
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: publicIPName
    }
    ipTags: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
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
        name: 'nalb'
        properties: {
          addressPrefix: vnetAddress
          networkSecurityGroup: {
            id: nsgId
          }
          delegations: []
        }
      }
    ]
  }
  resource symbolicname 'virtualNetworkPeerings' = if (vnetPeerWithId != '') {
    name: 'string'
    properties: {
      allowForwardedTraffic: true
      allowVirtualNetworkAccess: true
      remoteVirtualNetwork: {
        id: vnetPeerWithId
      }
    }
  }
}

resource nalb 'NGINX.NGINXPLUS/nginxDeployments@2021-05-01-preview' = {
  name: nginxDeploymentName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
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
        subnetId: vnet.properties.subnets[0].id
      }
    }
    enableDiagnosticsSupport: enableMetrics
  }
}

resource managedIdentityAssignment 'Microsoft.Authorization/roleAssignments@2018-09-01-preview' = if (enableMetrics) {
  scope: nalb
  name: guid(nginxDeploymentName, subscription().subscriptionId, resourceGroup().id)
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'
    principalId: reference(managedIdentityId, '2018-11-30').principalId
  }
}

var rootpath = '/etc/nginx/nginx.conf'
var configContent = '''
  http {{
    upstream app-1 {{
      zone app-1 64k;
      least_conn;
      {0}
    }}

    server {{
      listen 80 default_server;
      location /foo {{
        proxy_pass http://app-1/;
      }}
    }}
  }}
'''

resource config 'NGINX.NGINXPLUS/nginxDeployments/configurations@2021-05-01-preview' = {
  parent: nalb
  location: location
  name: 'default'
  properties: {
    rootFile: rootpath
    files: [
      {
        content: base64(format(configContent, workloadIP))
        virtualPath: rootpath
      }
    ]
  }
}
