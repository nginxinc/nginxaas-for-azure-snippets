@description('The name of the NGINX deployment resource to deploy the configuration')
param nginxDeploymentName string = 'myDeployment'

@description('The name of the NGINX certificate resource')
param certificateName string

@description('The file path of the NGINX certificate file')
param certificateVirtualPath string = '/etc/ssl/my-cert.crt'

@description('The file path of the NGINX certificate key file')
param keyVirtualPath string = '/etc/ssl/my-cert.key'

@description('The URI to the AKV secret for the certificate')
param keyVaultSecretId string

resource certificate 'NGINX.NGINXPLUS/nginxDeployments/certificates@2021-05-01-preview' = {
  name: '${nginxDeploymentName}/${certificateName}'
  properties: {
    certificateVirtualPath: certificateVirtualPath
    keyVirtualPath: keyVirtualPath
    keyVaultSecretId: keyVaultSecretId
  }
}
