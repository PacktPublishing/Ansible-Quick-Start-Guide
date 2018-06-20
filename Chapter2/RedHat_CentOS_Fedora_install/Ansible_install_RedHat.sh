#!/bin/bash

cd /tmp

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo rpm -i epel-release-latest-7.noarch.rpm

sudo yum update

sudo yum install -y ansible
