# Ansible Linux Modules

## Linux System Modules
```
# user modules playbook:
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: create a system user to be used by Ansible
      user:
        name: install
        state: present
        shell: /bin/bash
        group: sudo
        system: yes
        hidden: yes
        ssh_key_file: .ssh/id_rsa
        expires: -1
        
# group module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: create new group
      group:
        name: clustergroup
        state: present
        gid: 1040

# hostname module 
/etc/ansible/hosts
[servers]
server0 	ansible_host=192.168.10.10      
server1 	ansible_host=192.168.10.11     
server2 	ansible_host=192.168.10.12

~/playbook/module_playbook.yml
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: change hostname
      hostname:
        name: “{{ inventory_hostname }}”

ansible -m shell -a hostname servers

# sysctl module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: enable IP forwarding on IP version 4
      sysctl:
         name: net.ipv4.ip_forward
         value: 1
        sysctrl_set: yes
        state: present
       reload: yes

# service module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: start and enable ntp service
      service:
          name: ntp
          state: started
          enabled: yes

# systemd module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: start and enable ntp service using systemd
      systemd:
        name: ntp
        state: started
        enabled: yes
        masked: no
        daemon_reload: yes
      register: systemd

    - debug:
        var: systemd.status.Description

# kernel_blacklist module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: addling nouveau nvidia driver to the kernel blaklist
      kernel_blacklist:
         name: nouveau
         state: present

# cron module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: setup a cron job
      cron:
         name: “shared folder permission enforcer”
         special_time: daily
         hour: 0
         minute: 0
         day: *
         job: “chmod -R 777 /media/shared”
         state: present

    - name: link the cron PATH variable with a new binaries location
      cron:
         name: PATH
         env: yes
         value: /usr/local/app/bin

# make module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: compile an application 
      make:
        chdir: /usr/local/app
        target: install
        params:
          NUM_THREADS: 2

# Authrorized_key module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: add a new authorise SSH key to the user install
      authorized_key:
          user: install
          state: present
          key: "{{ lookup('file', '/home/install/.ssh/id_rsa.pub') }}"

# git module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: clone Ansible from github
      git:
        repo: https://github.com/ansible/ansible.git
        dest: /usr/local/ansible
        clone: yes
        update: yes

# selinux module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: change SELinux to permissive
      selinux:
        policy: targeted
        state: permissive
```
## Linux Commands Modules
```
# Raw module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: run a simple command
      raw: echo “this was written by a raw Ansible module!!” >> ~/raw.txt

# command module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: run a simple command
      command: cat ~/raw.txt
      register: rawtxt

    - debug: var=rawtxt.stdout

# shell module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: run a simple shell script
      shell: ./shell_script.sh >> ~/shell.txt
      args:
          chdir: /usr/local/
          creates: ~/shell.txt
          executable: /bin/sh

# script module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: execute a script on a remote host
      script: ./shell_script.py –some-argumets “42”
      args:
          creates: ~/shell.txt
          executable: python

# expect module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: change user1 password
      expect:
        command: passwd user1
        responses:
          (?i)password: "Ju5tAn07herP@55w0rd"
```
## Linux packages Modules
```
# apt module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: install some packages on a Debian OS
      apt:
        name: “{{ pkg }}”
        state: latest
        update_cache: yes
      vars:
         pkg:
         - nload
         - htop

# dnf module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: install a package using dnf
      dnf:
          name: htop
          state: latest

# yum module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: add epel repo using yum
      yum:
           name: https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
          state: present   

    - name: install ansible using yum
      yum:
           name: ansible
           state: present

# homebrew module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: remove a package using homebrew
      homebrew:
         name: htop
         state: absent
         update_homebrew: yes

# pip module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: install a python library from the default repo
      pip:
         name: numpy
         version: 0.3
    - name: install a python library from a github
      pip:
         name: https://github.com/jakubroztocil/httpie/archive/master.tar.gz

# cpanm module
---
- name: Linux Module running
  hosts: servers
  become: yes
  gather_facts: false
  tasks:
    - name: install a Perl library on a Linux host
      cpanm:
         name: ./IO-1.39.tar.gz
```
## Linux File Modules
```
# file (acl) modules
    - name: create a file with some specific acl
      file:
         path: /usr/local/script.py
         state: touch
         owner: user1
         group: developers
         mode: 0755
      
    - name: change acl of a file
      acl:
         path: /usr/local/script.py
         entity: user2
         permission: w
         state: present

# copy (unarchive, get_url) modules
    - name: copy file from within a remote host
      copy:
         src: /usr/local/script.py
         dest: /home/user1/script.py
         remote_src: yes
         owner: user1
         group: developers
         mode: 0755
      
    - name: extract an archive into remote hosts
      unarchive:
         src: ~/archive.tar.gz
         dest: /usr/local/
         owner: user1
         group: developers
         mode: 0755

    - name: download an ansible archive to remote hosts
      get_url:
         url: https://github.com/ansible/ansible/archive/v2.6.1.tar.gz
         dest: /usr/local/ansible_v2.6.1.tar.gz
         mode: 0777

# fetch module
    - name: Collect user files from remote hosts
      fetch:
         src: /home/user1/.profile
         dest: /home/alibi/user1-profile-{{ inventory_hostname }}
         flat: yes

# lineinfile (replace, blockinfile) modules
     - name: change a sudo user to no longer need password with config testing
      lineinfile:
         path: /etc/sudoers
         regexp: '^%sudo\s'
         line: '%sudo ALL=(ALL) NOPASSWD: ALL'
         state: present
         validate: '/usr/sbin/visudo -cf %s'

     - name: change all static ethernet config to use a higher mtu
      replace:
         path: /etc/network/interfaces
         regexp: '^mtu 1400$'
         line: 'mtu 9000'
         backup: yes
         validate: 'systemd reload networking'

     - name: change a static ethernet configuration
      replace:
         path: /etc/network/interfaces
         block: |
             iface eth1 inet dhcp
                   dns-nameserver 8.8.8.8
                   dns-nameserver 8.8.4.4
                   mtu 9000
         backup: yes
         validate: 'systemd reload networking'
```
## Linux Networking Modules
```
# inerfaces_file module
    - name: Change mtu to 1500 for eth1 interface
      Interfaces_file:
         dest: /etc/network/interfaces
         iface: eth1
         option: mtu
         value: 1500
         backup: yes
         state: present

# ufw module
    - name: add port 5000 for iperf testing on all hosts
      ufw:
         rule: allow
         port: 5000
         proto: tcp

# haproxy modules
    - name: disable a haproxy backend host
      haproxy:
         state: disabled
         host: '{{ inventory_hostname }}'
         socket: /usr/loca/haproxy/haproxy.sock
         backend: www
         wait: yes
```
## Linux Storage Modules
```
# filesystem module
    - name: create a filesystem from a newly added disk
      filesystem:
         fstype: ext4
         dev: /dev/sdc1

# mount module
    - name: mount the recently added volume to the system
      mount:
         path: /media/disk1 
         fstype: ext4
         boot: yes
         state: mounted
         src: /dev/sdc1

# parted module
    - name: remove a no longer needed partition
      mount:
         device: /dev/sdc
         number: 1
         state: absent

# gluster_volume module

    - name: create a new GlusterFS volume
      Gluster_volume:
         status: present
         name: gluster1
         bricks: /bridkes/brik1/g1
         rebalance: yes
         cluster: 
            - 192.168.10.10
            - 192.168.10.11
            - 192.168.10.12
         run_once: true
```


















                
