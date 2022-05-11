param workloadlocation string

param subnetid string

param name string

param backendPoolId string = ''

resource workloadvmpip 'Microsoft.Network/publicIpAddresses@2019-04-01' = {
  name: name
  location: workloadlocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: name
    }
  }
}

resource workloadvmnic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: name
  location: workloadlocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'

          subnet: {
            id: subnetid
          }
          loadBalancerBackendAddressPools: backendPoolId == '' ? [] : [
            {
              id: backendPoolId
            }
          ]
          // pip looks to be optional
          publicIPAddress: {
            id: workloadvmpip.id
          }
        }
      }
    ]
  }
}

var cloudinit = '''
#cloud-config
packages:
  - nginx
write_files:
  - path: /etc/nginx/sites-available/default
    content: |
      server {{
        listen 80 default_server;
        location / {
          default_type text/html;
          return 200 '<!DOCTYPE html><h2>Hello from $hostname!</h2>\n';
        }
      }
runcmd:
  - systemctl restart nginx
'''

resource workloadVM 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: name
  location: workloadlocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        diskSizeGB: 32
      }
    }
    osProfile: {
      computerName: name
      adminUsername: 'ubuntu'
      customData: base64(cloudinit)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+agW/EONIjKJ+ROLBzg5aefnqY4fZ2q7UGh+fFJJqDzL/DMZ+3LCc1Lbf9hFjojyAXmmE0Nf8rycalYb9Y2fx7cVL/DVTfKTsoc2hL5XE3YRdGZu7qFxnXECbRD02OhH8K38+nZwStK+auY/syyzJ7Rx3XTfiW9u5YpgYM7xmj0o5y53N/ozyF29F1vDNnYsWiy5ju7Yci4VJ5CprXu/H93DzuQkI7X9lUsrhUBHqRSJgHoJOCmgSzYWRWHoaQiNxfVNJojuswRHTlRE7PrVXKjDvEP3egbE03mLWh3CzHOpNlNFSJ2m8pEDu0QnbbetPr/xMXOOI+cR7vvJtCBa94VKURWl9OHeHdaxczDHvS5cIV4OxAEnOiHH1DuqW3EH4x0Y4bPCSlCSOAWUqJVYJa/En7kOCqZh01rF1R0DCvdVhxtQkqspUhhQPtjG8stxMJI/1de6OJs38kwQPyWsFjtxtOAl0jfH06HOoFXEIR49afgndtSrzf90goWtNL88='
              path: '/home/ubuntu/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: workloadvmnic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

output ip string = workloadvmnic.properties.ipConfigurations[0].properties.privateIPAddress
