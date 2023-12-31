@description('Application Gateway Name')
param appgwName string = 'appgw'


@description('Application Gateway Backend Address Pools')
param backendAddressPools array = [
  
    {
      name: 'appServiceBackendPool'
      properties: {
        backendAddresses: [
          {
            fqdn:'conappdemo.kinddune-8f348420.westeurope.azurecontainerapps.io'
          }
        ]
      }
    }]
 
@description('Application Gateway Backend Http Settings Collection')
param backendHttpSettingsCollection array = [
  {
    name: 'appServiceBackendHttpsSetting'
    properties: {
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: true
      port: 443
      protocol: 'Https'
      requestTimeout: 30
    }
  }

  ]

@description('Application Gateway Frontend IP Configurations')
param frontendIPConfigurations array = [
  {
    name: 'public'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      // privateLinkConfiguration: {
      //   id: '<id>'
      // }
      publicIPAddress: {
        id: '/subscriptions/628a5315-ad55-4071-8e32-cdaa725ce8ac/resourceGroups/appgwdemo/providers/Microsoft.Network/publicIPAddresses/pip-appgwdemo'
      }
    }
  }]

@description('Application Gateway Frontend Ports')
param frontendPorts array = [
  {
    name: 'port80'
    properties: {
      port: 80
    }
  }]

@description('Application Gateway Gateway IP Configurations')
param gatewayIPConfigurations array = [
  {
    name: 'apw-ip-configuration'
    properties: {
      subnet: {
        id: '/subscriptions/628a5315-ad55-4071-8e32-cdaa725ce8ac/resourceGroups/vnet-spoke/providers/Microsoft.Network/virtualNetworks/vnet-spoke-02-ne/subnets'
      }
    }
  }
]


@description('Application Gateway Http Listeners')
param httpListeners array = [
  {
    name: 'httpRedirect80'
    properties: {
      frontendIPConfiguration: {
        id: 'public'
      }
      frontendPort: {
        id: 'port80'
      }
      hostNames: []
      protocol: 'Http'
      requireServerNameIndication: false
    }
  }

]

@description(' Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints array = [
  
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    service: 'public'
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
]

@description('Application Gateway Probes')
param probes array = [
  {
    name: 'appgw-backend-probe'
    protocol: 'Http'
    host: ''
    path: '/'
    interval: 30
    timeout: 30
    unhealthyThreshold: 3
    pickHostNameFromBackendHttpSettings: false
    minServers: 0
  }]

@description('Application Gateway Request Routing Rules')
param requestRoutingRules array = [
  
]

@description('Application Gateway SKU')
param appgwSku string = 'Standard_v2'

@description('URL path map of the application gateway resource.')
param urlPathMaps array = [
  {
    name: 'appgw-url-path-map'
    defaultBackendAddressPoolName: 'appgw-backend-pool'
    defaultBackendHttpSettingsName: 'appgw-backend-http-settings'
    // defaultRewriteRuleSetId: ''
    pathRules: [
      {
        name: 'appgw-path-rule'
        paths: [
          '/*'
        ]
        backendAddressPoolName: 'appgw-backend-pool'
        backendHttpSettingsName: 'appgw-backend-http-settings'
        // rewriteRuleSetId: ''
      }
    ]
  }
]





// module vnet './modules/network/virtual-network/main.bicep' = {
//   name: 'vnet-deployment'
//   scope: resourceGroup('rg-appgw')
//   params: {
//     name: 'appgw-vnet'
//     addressPrefixes: [
//       '']
//     subnets: [
//       {
//         name: 'appgw-subnet'
//         addressPrefix: ''
//       }
//     ]}}




module appgw './modules/network/application-gateway/main.bicep' = {
  name: 'appgw-deployment'
  scope: resourceGroup('appgwdemo')
  params: {
    name: appgwName
    backendAddressPools: backendAddressPools 
    backendHttpSettingsCollection: backendHttpSettingsCollection
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: frontendPorts
    gatewayIPConfigurations: gatewayIPConfigurations
    httpListeners: httpListeners
    // privateEndpoints: privateEndpoints
    probes: probes
    requestRoutingRules: requestRoutingRules
    sku: appgwSku
    urlPathMaps: urlPathMaps
  }}




output appgwName string = appgw.outputs.name
output appgwId string = appgw.outputs.resourceId

