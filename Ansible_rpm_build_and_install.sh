#!/bin/bash

cd /tmp

sudo yum install -y git make

git clone https://github.com/ansible/ansible.git
cd ansible

make rpm

sudo rpm -Uvh rpm-build/ansible-*.noarch.rpm
