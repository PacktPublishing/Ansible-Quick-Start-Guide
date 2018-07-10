# Ansible playbook
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
