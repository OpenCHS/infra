#!/bin/bash
sudo systemctl stop kibana.service 2>&1 > /dev/null
sudo yum install -y kibana
sudo /bin/systemctl daemon-reload 2>&1 > /dev/null
sudo /bin/systemctl enable kibana.service 2>&1 > /dev/null
sudo systemctl start kibana.service