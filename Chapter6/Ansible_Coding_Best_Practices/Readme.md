# Ansible Coding Best Practices

## Comments usage in playbooks 
```
---
####################################
#
# This playbook with a goal to achieve number of tasks in a pipeline
# to configure several Linux hosts for collaborative projects. It starts by
# setting up the needed tools and services, then configure them to a 
# standard, then prepared the shared space, and assign the users and groups.
#
# Author: ***** ***** email: *********@****
#
####################################
- name: Hosts provisioning playbook
  hosts: linuxservers
  become: yes
  remote_user: setup
  gather_facts: false
  tasks:
    - name: Install Midnight commander
      # This is a terminal based file manager does not require a GUI interface
      apt:
       name: mc
…
```
## Avoid using commands modules
```
    - name: Execute a Windows Write Filter enabling command and identify if it made change
      win_shell: ewfm.exe -conf enable
      register: output
      changed_when: "output.stdout == 'Awaiting for next boot to apply the change.'" 
```
## Good usage for Ansible conditions
```
---
- name: Install python development package on Linux hosts
  hosts: linuxservers
  become: yes
  remote_user: setup
  gather_facts: true
  tasks:
    - name: install python development on Debian systems
      apt: 
          name: python-dev
      when: 'ansible_distribition == "Debian"'

    - name: install python development on Red Hat systems
      yum: 
          name: python-devel
      when: 'ansible_distribition == "RedHat"'
```
## Smarter usage for Ansible loops
```
---
- name: Copy users config files to their project directory
  hosts: linuxservers
  become: yes
  remote_user: setup
  gather_facts: true
  tasks:
    - name: Copy user config files 
      copy: 
          src: '{{ item.src  }}'
          dest: '{{  item.dest }}'
          mode: '{{ item.mode | default("0744")  }}'
          owner:  '{{ item.owner | default("nobody") }}'
      when_items: 
        - '{{ src="/media/share/config/user1.conf" dest="/usr/loca/projetsfolder/user1" mode="0774" owner="user1" }}'
        - '{{ src="/media/share/config/user2.conf" dest="/usr/loca/projetsfolder/user2" mode="0700" owner="user2" }}'
        - '{{ src="/media/share/samples/users.conf" dest="/usr/loca/projetsfolder/" mode="0777" }}'
```
## Template file usage
```
db.conf.j2:
mysql_db_hosts = '{{ db_serv_hostname  }}'
mysql_db_name = '{{ db_name }}'
mysql_db_user = '{{ db_username  }}'
mysql_db_pass = '{{ db_password  }}'

---
- name: Copy Database configuration file
  hosts: linuxservers
  become: yes
  remote_user: setup
  gather_facts: true    
  tasks:
    - name: Import varible from an otehr YAML
      include_vars: /home/admin/variables/database2.yml
      
    - name: Copy db config file 
      template: 
          src: /home/admin/template/db.conf.j2
          dest: /etc/mysql/db.conf
          owner: bin
          group: wheel
          mode: 0600
```
## Stating tasks status
```
  tasks:
    - name: create a new file
      file: 
          path: /usr/local/projects/vars.txt
          state: present

    - name: removing line to a file
      lineinfile: 
          path: /usr/local/projects/conf.txt
          line: "adminuser = user0"
          state: absent
```
## Shared storage space for data tasks
```
  tasks:
    - name: Copy a tool archive to remote host 
      copy: 
          src: /media/nfshsare/Tools/tool1.tar.gz
          dest: /usr/local/tools/
          mode: 0755

```
