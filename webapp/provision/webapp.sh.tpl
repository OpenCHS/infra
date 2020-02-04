#!/bin/bash


sudo rm -rf /opt/openchs-webapp
sudo wget -P /opt/openchs-webapp https://${build_version}-172675608-gh.circle-artifacts.com/0/~/artifacts/build.zip
sudo unzip /opt/openchs-webapp/build.zip -d /opt/openchs-webapp
sudo rm -rf /opt/openchs-webapp/build.zip
