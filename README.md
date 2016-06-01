# AEM Mobile Dashboard Customizations

Every mobile app has its own set of unique requirements. 
The AEM Mobile dashboard is a powerful tool that can be leveraged in order to ensure every mobile app can
be managed as efficiently as possible.

This project provides serveral customizations that can be applied to an app's [AEM Mobile](https://aemmobile.adobe.com) Dashboard.


## Minimum requirements

1. Maven (tested: Apache Maven `3.2.2`)
2. Git (tested: git version `2.3.2`)
6. AEM 6.2

## Install AEM Package

    mvn -PautoInstallPackage clean install
    
## Instance Resource Type

The resourceType given to your mobile app instance drives the entire dashboard experience. Extending the
core mobileapps resourceType provides a convenient way to alter existing dashboard functionality.

Core Instance Type: `/libs/mobileapps/core/components/instance`
PhoneGap Instance Type: `/libs/mobileapps/phonegap/components/instance`

### Catalog Card

Each app instance component may override the default [card](content/jcr_root/apps/planetrumsey/mobileapps/components/instance/card.jsp) rendering used by the Catalog view. 

### App Details Dialog

The [dialog](content/jcr_root/apps/planetrumsey/mobileapps/components/instance/_cq_dialog/.content.xml) used by the App Details view can be completely altered to meet an app's specific requirements. 
You don't want to expose app store properties? Remove it! 
You have specific meta data that needs to be stored with your app? Add a new dialog tab!
The possibilities are endless.

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

Now it is time to be creative. Dashboard tiles are meant to provide an immediate snapshot on the state of your app.
How many pages are currently staged?
Is the app part of a workflow?
How many users does the app have?

Any functionality your app requires can be represented by a tile to ensure it can be managed efficiently.
