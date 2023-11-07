@description('The name of the NGINX deployment resource to deploy the configuration')
param nginxDeploymentName string

@description('The file path of the root NGINX configuration file')
param rootConfigFilePath string = 'nginx.conf'

@description('The based64 encoded content of the root NGINX configuration file')
param rootConfigContent string

resource config 'NGINX.NGINXPLUS/nginxDeployments/configurations@2023-04-01' = {
  name: '${nginxDeploymentName}/default'
  properties: {
    rootFile: rootConfigFilePath
    files: [
      {
        content: rootConfigContent
        virtualPath: rootConfigFilePath
      }
    ]
  }
}
