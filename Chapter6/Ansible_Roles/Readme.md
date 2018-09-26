# Ansible Roles

## What are Ansible Roles

### Tasks folder
```
tasks/main.yml:
---
    - name: check if NTP is installed
      stat:  
          path: /etc/init.d/ntp
      register: tool_status

    - include_tasks: debian.yml 
      when: not tool_status.stat.exisits

    - name: Copy the NTP config to remote host 
      template: 
          src: ntp.conf.j2
          dest: /etc/ntp.conf
          mode: 0400
      notify: 
           - Restart ntp

tasks/debian.yml:
---
    - name: install ntp on the remote host 
      apt: 
          name: ntp
          state: latest

```
### Handlers folder
```
handlers/main.yml:
---
    - name: Restart ntp
      service: 
          name: ntp
          state: restarted
```
### Vars folder
```
vars/main.yml:
---
ntpserv1: 0.uk.pool.ntp.org
ntpserv2: 1.uk.pool.ntp.org
```
### Templates folder
```
template/ntp.conf.j2:
driftfile /var/lib/ntp/ntp.drift
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

loop {{ ntpserv1 }}
loop {{ ntpserv2 }}

pool ntp.ubuntu.com
restrict -4 default kod notrap nomodify nopeer noquery limited
restrict -6 default kod notrap nomodify nopeer noquery limited
restrict 127.0.0.1
restrict ::1
restrict source notrap nomodify noquery
```
### Defaults folder
```
defaults/main.yml:
---
timout: 2000
ID_key: "None"
```
### Meta folder
```
meta/main.yml:
---
galaxy_info:
  author: medalibi
  description: NTP client installn
  company: Packt
  license: license (GPLv3, BSD)
  min_ansible_version: 2.4
  platforms:
    - name: Ubuntu
      version:
        - 16.04
        - 18.04
  galaxy_tags:
    - networking
    - system

dependencies: []
```
### Test folder
```
tests/test.yml:
---
- hosts: servers
  remote_user: setup
  become: yes
  roles:
    - ntpclient.lab.edu
```
## Create Ansible Roles
```
# Role creation
cd ~/Roles/
ansible-galaxy init samba.lab.edu

# Role folder structure
samba.lab.edu
└── README.md
├── defaults
│   └── main.yml
├── files
│    
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
│    
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

# Role folders and files
template/smb.conf.j2:
#========= Global Settings =========
# Samba server configuration:
[global]
 workgroup = {{ wrk_grp | upper }}     ## upper convert any input to uppercase.
 server string = Samba Server %v
 netbios name = {{ os_name }}
 security = user
 map to guest = bad user
 dns proxy = no

#========= Share Definitions =========
# Samba shared folder:
[{{ smb_share_name }}]
 path = {{ smb_share_path }}
 valid users = @{{ smb_grp }}
 guest ok = no
 read only = no
 browsable =yes
 writable = yes
 force user = nobody
 create mask = {{ add_mod }}
 directory mask = {{ dir_mod }}

files/Fileserver_rules.txt:
This shared drive is to be used by designated teams. 
Any distractive usage will cause a follow up on the incident. 
Please do not change any of your team members folders or delete anything you are not assigned to manage.

For any inquiries please contact admin@edu.lab

meta/main.yml
---
dependencies: []

galaxy_info:
  author: medalibi
  description: "Samba server setup and configuration on Linux OS (Debian/Red Hat)"
  license: "license (GPLv3, BSD)"
  min_ansible_version: 2.5
  platforms:
    - name: Debian
      versions:
      - 8
      - 9
    - name: Ubuntu
      versions:
      - 14.04
      - 16.04
      - 18.04
    - name: EL
      versions:
        - 6
        - 7

  galaxy_tags:
    - system
    - networking
    - fileserver
    - windows

vars/main.yml
---
debian_smb_pkgs:
   - samba
   - samba-client
   - samba-common
   - python-glade2
   - system-config-samba

redhat_smb_pkgs:
   - samba
   - samba-client
   - samba-common
   - cifs-utils


smb_selinux_pkg:
  - libsemanage-python

smb_selinux_bln:
  - samba_enable_home_dirs
  - samba_export_all_rw

samba_config_path: /etc/samba/smb.conf

debian_smb_services:
   - smbd
   - nmbd

redhat_smb_services:
  - smb
  - nmb

defaults/main.yml:
---
wrk_grp: WORKGROUP
os_name: debian
smb_share_name: SharedWorkspace
smb_share_path: /usr/local/share
add_mod: 0700
dir_mod: 0700

smb_grp: smbgrp
smb_user: 'shareduser1'
smb_pass: '5h@redP@55w0rd'

tasks/Debian_OS.yml:
---
- name: Install Samba packages on Debian family Linux
  apt:
    name: "{{ item }}"
    state: latest
    update_cache: yes
  with_items: "{{ debian_smb_pkgs }}"


tasks/RedHat_OS.yml:
---
- name: Install Samba packages on Red Hat family Linux
  yum:
    name: "{{ item }}"
    state: latest
    update_cache: yes
  with_items: "{{ redhat_smb_pkgs }}"

- name: Install SELinux packages for Red Hat
  yum:
    name: "{{ item }}"
    state: present
  with_items: "{{ smb_selinux_pkg }}"

- name: Configure Red Hat SELinux Boolean
  seboolean:
    name: "{{ item }}"
    state: true
    persistent: true
  with_items: "{{ smb_selinux_bln }}"

tasks/main.yml:
---
- name: Setup Samba based on host OS
  include_tasks: "{{ item }}"
  with_items:
    - "{{ ansible_os_family }}_OS.yml"

- name: Create the Samba share access group 
  group:
    name: "{{ smb_grp }}"
    state: present

- name: Create the Samba access user
  user:
    name: "{{ smb_user }}" 
    groups: "{{ smb_grp }}" 
    append: yes
  
- name: Define the user password within Samba 
  shell: "(echo {{ smb_pass }}; echo {{ smb_pass }}) | smbpasswd -s -a {{ smb_user }}"

- name: Check that  the shared directory exist
  stat:
    path: "{{ smb_share_path }}"
  register: share_dir

- name: Make sure the shared directory is present
  file:
    state: directory
    path: "{{ smb_share_path }}"
    owner: "{{ smb_user  }}"
    group: "{{ smb_grp }}"
    mode: '0777'
    recurse: yes
  when: share_dir.stat.exists == False

- name: Deploy the Samba configuration file
  template:
    dest: "{{ samba_config_path }}"
    src: smb.conf.j2
    validate: 'testparm -s %s'
    backup: yes
  notify:
    - Restart Samba

- name: Enable and start Samba services on Debian family
  service:
    name: "{{ item }}"
    state: started
    enabled: true
  with_items: "{{ debian_smb_services }}"
  when: ansible_os_family == 'Debian'

- name: Enable and start Samba services on RedHat family
  service:
    name: "{{ item }}"
    state: started
    enabled: true
  with_items: "{{ redhat_smb_services }}"
  when: ansible_os_family == 'RedHat'

/handlers/main.yml:
---
- name: Restart Samba
  service:
    name: "{{ item }}"
    state: restarted
  with_items: "{{ debian_smb_services }}"
  when: ansible_os_family == 'Debian'

- name: Restart Samba
  service:
    name: "{{ item }}"
    state: restarted
  with_items: "{{ redhat_smb_services }}"
  when: ansible_os_family == 'RedHat'
```
## Ansible Roles usage
```
tests/inventory:
[linuxserver]
node0
node1
node2

tests/test,yml:
- hosts: linuxserver
  remote_user: setup
  become: yes
  roles:
    - samba.lab.edu
```
