targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// add
param repositoryUrl string = 'https://github.com/erleonard/art-gallery-chat-app'
param branch string = 'master'

@description('The app location for the static site')
param appLocation string = '/'

@description('The API location for the static site')
param apiLocation string = '/api'

@description('The app artifact location for the static site')
param appArtifactLocation string = 'public'

@description('Whether distributed backends are enabled for the static site')
param areStaticSitesDistributedBackendsEnabled bool = false

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
//var tags = {
//  'azd-env-name': environmentName
//}

@description('String to make resource names unique')
var random = uniqueString(subscription().subscriptionId, location)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
}

@description('Create a static web app')
module swa 'br/public:avm/res/web/static-site:0.6.1' = {
  name: 'staticSiteDeployment'
  scope: rg
  params: {
    name: 'swa-${random}'
    location: location
    sku: 'Standard'
    //link to repo for running gh actions
    // repositoryUrl: repositoryUrl
    // branch: branch
    // appSettings: {
      // APP_LOCATION: appLocation
      // API_LOCATION: apiLocation
      // APP_ARTIFACT_LOCATION: appArtifactLocation
      // ARE_STATIC_SITES_DISTRIBUTED_BACKENDS_ENABLED: areStaticSitesDistributedBackendsEnabled
    // }
  }
}

@description('Output the default hostname')
output endpoint string = swa.outputs.defaultHostname

@description('Output the static web app name')
output staticWebAppName string = swa.outputs.name
