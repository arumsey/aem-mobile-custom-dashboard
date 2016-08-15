#!/usr/bin/env bash

curl -u admin:admin -X POST --data "sling:resourceType=arumsey/mobileapps/components/instance" http://localhost:4502/content/mobileapps/hybrid-reference-app/shell/jcr:content
