param name string

param location string = resourceGroup().location

module n1 'n4a.bicep' = {
  name: 'n1'
  params: {
    name: name
    location: location
    vnetAddress: '172.25.1.0/24'
    publiciplabel: name
  }
}
