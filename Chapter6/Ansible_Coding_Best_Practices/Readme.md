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
##
