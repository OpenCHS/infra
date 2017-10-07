#!/bin/bash
sudo systemctl stop logstash.service 2>&1 > /dev/null
sudo yum install -y logstash
sudo /bin/systemctl daemon-reload 2>&1 > /dev/null
sudo /bin/systemctl enable logstash.service 2>&1 > /dev/null
sudo systemctl start logstash.service