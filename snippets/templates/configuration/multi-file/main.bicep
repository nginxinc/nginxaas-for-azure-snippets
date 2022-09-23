@description('The name of the NGINX deployment resource to deploy the configuration')
param nginxDeploymentName string

@description('The file path of the root NGINX configuration file')
param rootFile string = '/etc/nginx/nginx.conf'

@description('The based64 encoded NGINX configuration tarball')
param tarball string

resource config 'NGINX.NGINXPLUS/nginxDeployments/configurations@2021-05-01-preview' = {
  name: '${nginxDeploymentName}/default'
  properties: {
    rootFile: rootFile
    package: {
      data: tarball
    }
  }
}
