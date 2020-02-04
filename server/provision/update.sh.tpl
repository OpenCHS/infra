#!/bin/bash
sudo service openchs stop 2>&1 >/dev/null
sleep 5

sudo yum clean all 2>&1 >/dev/null
sudo rm -rf /var/cache/yum 2>&1 >/dev/null
sudo yum -y updateinfo 2>&1 >/dev/null
sudo yum -y remove openchs-server java-1.7.0-openjdk 2>&1 >/dev/null
sudo yum -y install https://${minor_version}-64591222-gh.circle-artifacts.com/0/~/artifacts/openchs-server-${major_version}-${minor_version}.noarch.rpm 2>&1 >/dev/null
sudo mv /tmp/openchs.conf /etc/openchs/openchs.conf 2>&1 >/dev/null
sudo service openchs start 2>&1 >/dev/null

sleep 20
