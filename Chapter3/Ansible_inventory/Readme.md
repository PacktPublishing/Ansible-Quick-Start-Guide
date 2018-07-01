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
# Group variable defining
[labserver]
node0.lab.edu
node1.lab.edu

[labserver:vars]
ansible_connection=ssh
ansible_port=22

# Groups of host groups
[webservers]
node0.lab.edu
node1.lab.edu

[fileserver]
node2.lab.edu
node3.lab.edu

[server:children]
webservers
fileserver
# Parenet groups variable defining
[servers:vars]
ansible_user=setup
ansible_private_ssh_key=/home/user/ansible.key
# Group variable files default location
/etc/ansible/group_vars/webserver
/etc/ansible/group_vars/fileserver
# YAML group varibales files structre
---
ansible_user=setup
ansible_private_ssh_key=/home/user/ansible.key
```
## Ansible playbook
```
# Sample playbook file
nano ~/playbooks/apt_cache.yml

---
- name: playbook to update Debian Linux package cache 
  hosts: servers
  tasks:
  - name: use apt to update its cache
    apt:
        update_cache: yes
    become: yes
# Playbook without names
---
- hosts: servers
  gather_facts: False
  tasks:
  - apt:
        update_cache: yes
    become: yes
# Variabels defined at the play level
---
- name: playbook to update Debian Linux package cache 
  hosts: servers
  remote_user: setup
  become: yes
  tasks:
# Varibales defined at the taks level
---
- name: playbook to update Debian Linux package cache 
  hosts: servers
  tasks:
  - name: use apt to update its cache
    apt:
        update_cache: yes
    become: yes
    become_user: setup
# Task written in one liner with a descriptive name
tasks:
   - name: use apt to update its cache
     apt: update_cache=yes
# Task writen in a broken down mode with errors ignored when task failed
tasks:
   - name: use apt to update its cache
     apt: 
         update_cache: yes
     ignore_errors: True
# Ansible handlers usage 
  tasks:
  - name: use apt to update its cache
    apt:
        update_cache: yes
    become: yes
    notify: pkg_installable

  handlers:
  - name: pkg_installable
    apt:
        name: htop
        state: latest
    become: yes
# playbook with condition for execution
  tasks:
  - name: use apt to update all apps for Debian family
    apt:
        name: "*"
        state: latest
        update_cache: yes
    become: yes
    when: ansible_os_family == “Debian”

  - name: use yum to update all apps for Red Hat family
    yum:
        name: '*'
        state: latest
    become: yes
    when: ansible_os_family == “Red Hat”
# setup a list of applications using playbooks
  tasks:
  - name: use apt to install multiple apps
    apt:
        name: “{{ app }}”
        state: latest
        update_cache: yes
    vars:
        app:
        - htop
        - mc
        - nload
    become: yes

# setup a list of applications using loop on playbooks
  tasks:
  - name: use apt to install multiple apps
    apt:
        name: “{{ item }}”
        state: latest
        update_cache: yes
    loop:
        - htop
        - mc
        - nload
    become: yes
```
