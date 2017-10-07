#!/bin/bash
sudo yum install -y java-1.8.0-openjdk-devel
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch 2>&1 > /dev/null
