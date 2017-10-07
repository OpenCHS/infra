#!/bin/bash
sudo systemctl stop elasticsearch.service 2>&1 > /dev/null
sudo yum install -y elasticsearch
sudo /bin/systemctl daemon-reload 2>&1 > /dev/null
sudo /bin/systemctl enable elasticsearch.service 2>&1 > /dev/null
sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml 2>&1 > /dev/null
sudo systemctl start elasticsearch.service