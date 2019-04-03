#!/bin/bash

sudo rm -rf /opt/openchs/static/
sudo wget -P /opt/openchs/static/ https://${build_version}-172675608-gh.circle-artifacts.com/0/home/circleci/artifacts/build.zip
sudo unzip /opt/openchs/static/build.zip -d /opt/openchs/static
sudo rm -rf /opt/openchs/static/build.zip
