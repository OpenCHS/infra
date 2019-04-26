#!/bin/bash

WEBAPP_DIR=/opt/openchs-webapp

sudo rm -rf ${WEBAPP_DIR}
sudo wget -P ${WEBAPP_DIR} https://${build_version}-172675608-gh.circle-artifacts.com/0/home/circleci/artifacts/build.zip
sudo unzip ${WEBAPP_DIR}/build.zip -d ${WEBAPP_DIR}
sudo rm -rf ${WEBAPP_DIR}/build.zip
