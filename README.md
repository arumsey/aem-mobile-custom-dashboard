# AEM Apps Custom Tile

This project creates a custom tile that can be used as part of the AEM Apps dashboard.

## Minimum requirements

1. Maven (tested: Apache Maven `3.2.2`)
2. Git (tested: git version `2.3.2`)
6. AEM 6.1

## Install AEM Package

    mvn -PautoInstallPackage clean install
    
## Using a Custom Tile

In order to use a custom tile with your app you will need to specify a custom dashboard config. The `pge-dashboard-config` 
property needs to be added to the `jcr:content` of your app's instance node (ie. shell).

eg.

    /content/phonegap/geometrixx-outdoors/shell/jcr:content
      + pge-dashboard-config = /apps/custom-tile/content/dashboard/tiles/custom 

