# Ansible Inventory

## Ansible Inventory file

```
# using a specific inventory other than the system default
sudo nano /etc/ansible/ansible.cfg
inventory      = /home/user1/ansible/hosts
# Or 
ansible -m ping -i ~/ansible/hosts
# Host group classification
[webserver]
192.168.10.10
192.168.10.12

[mysqldb]
192.168.10.10
192.168.10.20

[fileserver]
192.168.10.11
192.168.10.20

```

## Static inventory 
```
nano /etc/ansible/hosts

# Inventory without simplification based on pattern
[servers]
node0.lab.edu
node1.lab.edu
node2.lab.edu
node3.lab.edu
node4.lab.edu
# A simplified ineventory based a pattern
[servers]
Node[0:4].lab.edu


# INI file structre
[webserver]
192.168.10.10
192.168.10.12

[mysqldb]
192.168.10.10
192.168.10.20

[fileserver]
192.168.10.11
192.168.10.20

# YAML file structre
all:
   hosts:
        node0.lab.edu
   children:
        lab1servers:
            hosts:
                 node1.lab.edu
                 node2.lab.edu
        lab2server:
            hosts:
                 node3.lab.edu

# Inventory host specific variables
ansibleserv		ansible_connection: local
fileserver		ansible_host: 192.168.10.10	ansible_port:22
node1.lab.edu		ansible	user: setup  ansible_ssh_private_key:/home/user/node1.key
node2.lab.edu		ansible_become: yes	ansible_become_user: user1


```
## Ansible playbook
```
nano ~/playbooks/playbook.yml


```
