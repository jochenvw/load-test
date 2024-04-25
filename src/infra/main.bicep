param location string = 'swedencentral'
var resourcePrefix = 'nl-jvw'

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${resourcePrefix}-lt-logs'
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
  }
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourcePrefix}-lt-applogs'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

resource asp 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${resourcePrefix}-lt-service-plan'
  location: location
  kind: 'linux'
  sku: {
    tier: 'ElasticPremium'
    name: 'EP1'
  } 
  properties: {
    reserved: true
    zoneRedundant: true
    elasticScaleEnabled: true 
    maximumElasticWorkerCount: 20  
  } 
}


resource azureFunction 'Microsoft.Web/sites@2023-01-01' = {
  name: '${resourcePrefix}-lt-app'
  location: location
  kind: 'functionapp,linux'
  tags: {
  }
  properties: {
    serverFarmId: asp.id
    siteConfig: {
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appinsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appinsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcstore.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcstore.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcstore.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcstore.listKeys().keys[0].value}'
        }
      ]
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
    }
  }
}

resource loadtest 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: '${resourcePrefix}-lt-loadtest'
  location: location
}

resource funcstore 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: replace('${resourcePrefix}ltfuncstore','-','')
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_ZRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
  }
}
