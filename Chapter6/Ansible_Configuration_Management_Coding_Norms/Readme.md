# Ansible Configuration Management Coding Norms

## Playbooks and tasks naming
```
# Nameless playbook and tasks
---
- hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - apt: update_cache=yes
    - apt:
       name: mc
    - file:
       path: /usr/local/projects
       mode: 1777
       state: directory

# Properly named playbook and tasks
---
- name: Setup users projects workspace with a file manager
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: Update Package manager repo index
      apt: update_cache=yes
    - name: Install Midnight commander as a terminal file manager
      apt:
       name: mc
    - name: Create the projects workspace folder with sticky bit
      file:
       path: /usr/local/projects
       mode: 1777
       state: directory
```
## YAML syntax usage for playbooks
```
# One-liner tasks
   - name: Copy user configuration
     copy: src=/home/admin/setup.conf dest=/usr/local/projects/ owner=setup group=dev mode=0677 backup=yes 

# Task folowing YAML syntax
   - name: Copy user configuration
     copy: 
       src: /home/admin/setup.conf
       dest: /usr/local/projects/
       owner: setup
       group: dev
       mode: 0677
       backup: yes
       
# Multi lined string
   - name: Fill in sample text file
     lineinfile:
       path: /usr/local/projects/setup.conf
       line: >
                This is the configuration file for the user
                Setup. Please do not edit make any change 
                to it if you are not and administrator.

```
## Become usage
```
---
- name: Organise users projects folders
  hosts: servers
  become: yes
  remote_user: setup
  gather_facts: false
  tasks:
    - name: create folder for user1
      command: mkdir /usr/local/projects/user1
      become_user: user1
       
    - name: Create test space for setup
      file:
       path: /usr/local/projects/setup/test
       mode: 1777
       state: directory
```
## Group organisation
```
/etc/ansible/hosts:
[linuxservers:children]
webservers
loadbalancers

[linuxservers:vars]
remote_user: setup
ntpserver: 0.uk.pool.ntp.org
become: yes

[webservers]
node0
node1
node2

[webservers:vars]
remote_user: devadmin
ansible_connection: ssh

[loadbalancers]
node3
node4

[loadbalancers:vars]
ntpserver: 0.us.pool.ntp.org
ansible_connection: docker
```
## Handlers usage
```
---
- name: Change service settings and apply it
  hosts: servers
  become: yes
  remote_user: setup
  gather_facts: false
  tasks:
    - name: Flush the playbook handlers
      meta: flush_handlers

    - name: Change ntp service config
      lineinfile:
       path: /etc/ntp.conf
       line: "server 0.us.pool.ntp.org"

    - name: Flush the playbook handlers
      meta: flush_handlers

  handlers:
    - name: restart ntp service
      service:
       name: ntp
       state: restarted
```
## Password usage in playbooks
```
---
- name: usage of sensative variable
  hosts: servers
  include: passwords_playbook.yml
  tasks:
    - name: add a MySQL user
      mysql_user:
        name: user1
        password: {{ mysql_user1_password }}
        priv: '*.*:ALL'
        state: present  
```
