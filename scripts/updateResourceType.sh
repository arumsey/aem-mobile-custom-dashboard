#!/usr/bin/env bash

curl -u admin:admin -X POST --data sling:resourceType=arumsey/mobileapps/components/instance  http://localhost:4502/content/mobileapps/we-healthcare-tracker/shell/jcr:content
