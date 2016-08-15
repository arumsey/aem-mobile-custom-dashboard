#!/usr/bin/env bash

curl -u admin:admin -X POST --data "sling:resourceType=mobileapps/phonegap/components/instance" --data "pge-dashboard-config@Delete" http://localhost:4502/content/mobileapps/hybrid-reference-app/shell/jcr:content
