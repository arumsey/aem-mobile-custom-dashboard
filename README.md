# AEM Mobile Dashboard Customizations

This project provides serveral customizations that can be applied to the [AEM Mobile](https://aemmobile.adobe.com) Dashboard.

## Minimum requirements

1. Maven (tested: Apache Maven `3.2.2`)
2. Git (tested: git version `2.3.2`)
6. AEM 6.2

## Install AEM Package

    mvn -PautoInstallPackage clean install
    
## Instance Resource Type

The resourceType given to your mobile app instance drives the entire dashboard experience. Extending the
core mobileapps resourceType provides a convenient way to alter existing dashboard functionality.

### Catalog Card

### App Details Dialog

### App Template

The [app template](content/jcr_root/apps/planetrumsey/mobileapps/templates/app-hybrid-custom) will allow any new app that is created to
automatically obtain any desired dashboard customizations.


## Dashboard Configuration

Each mobile app instance in AEM can specify its own dashboard tile configuration. The can include removing any default tiles as well as
adding new tiles. The `pge-dashboard-config` property needs to be added to the `jcr:content` of your app's instance node (ie. shell).

eg.

    /content/phonegap/geometrixx-outdoors/shell/jcr:content
      + pge-dashboard-config = /apps/planetrumsey/mobileapps/dashboard/dps/custom 


### Custom Tiles

