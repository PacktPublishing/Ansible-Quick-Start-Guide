# Master node essential configuration
## Edit Ansible configruation file
```
sudo nano /etc/ansible/ansible.cfg
```
## SSH key usage
```
# Create the ssh key
ssh-keygen -t rsa
# Copy the key to the to be managed host
ssh-copyid user@host1
```
## Expect install
```
# Install expect on Redhat
sudo yum install -y expect-devel
# Install expect on Debian
sudo apt install -y expect
# Install expect on Mac OS X
brew install expect
```
# Expect script for ssh key distrubition
```
#!/usr/bin/expect -f

set login "install"
set addr [lindex $argv 0]
set pw [lindex $argv 1]
spawn ssh-copyid $login@$addr
expect "*yes/no*" {
    send "yes\r"
    expect "*?assword*" { send "$pw\r" }
    } "*?asswor*" { send "$pw\r" }
interact
```
# Sample Bash script to use expect script
```
#!/bin/bash

password=`cat /root/installpassword.txt`

for j in 10 11 12 13 14 15 16 17 18 19 20 
do

./expectscript 192.168.1.$j $password

done
```
# Ansible usage to distrubite sssh keys to hosts
```
ansible all -m copy -a "src=~ /.ssh/id_rsa.pub dest=/tmp/id_rsa.pub" --ask-pass -c install
ansible all -m shell -a "cat /tmp/id_rsa.pub >> /home/install/.ssh/authorized_keys" --ask-pass -c install
```
