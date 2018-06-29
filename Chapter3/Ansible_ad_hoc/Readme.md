# Ansible ad hoc usage

## localhost ansible ad hoc command test 
```
# Ping localhost to check ansible's usability
ansible localhost -m ping
# Run a raw command
ansible localhost -a “echo ‘Hello automated World’”
```
## Run Ansible ad hoc command on a different host
```
# Run an ad hoc raw command to collect host information
ansible 192.168.10.10 -a "uname -a" -u setup
# Run and ad hoc priviliged command
ansible 192.168.10.10 -a "apt update" -u setup --become
# Run a package module to update its cache
ansible 192.168.10.10 -m apt -a "update_cache=yes" -u setup --become
# Run a command on a differnet user in the remote host
ansible 192.168.10.10 -a "whoami" -u setup --become --become-user user1
```
## Exectute ad hoc command on multiple hosts
```
# Edit Ansibel hosts file to group a number of hosts under one name
nano /etc/ansible/hosts
# Group of hosts added staticaly looks like the hosts file
[servers]
192.168.10.10
192.168.10.11
192.168.10.12
# Copy file to all hosts using the copy module
ansible servers -m copy -a “src=/home/user/file.txt dest=/home/setup/file.txt” -u setup
# initiate service restart on multiple hosts simultaneously 
ansible servers -m service -a "name=httpd state=restarted" -u setup –become -f 1
```
