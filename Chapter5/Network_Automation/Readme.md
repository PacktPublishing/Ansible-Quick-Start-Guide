# Network Automation

## Use case 1: Automate patching network devices

```
---
- name:  Patch CISCO network devices 
  hosts: ciscoswitches
  remote_user: admin
  strategy: debug
  connection: ssh
  serial: 1
  gather_facts: yes
  tasks:
    - name: Backup the running-config and the startup-config to the local machine
      ntc_save_config:
         local_file: "images/{{ inventory_hostname }}.cfg"
         platform: 'cisco_ios_ssh'
         username: admin
         password: "P@55w0rd"
         secret: "5ecretP@55"
         host: "{{ inventory_hostname }}"

    - name: Upload binary file to the CISCO devices
      ntc_file_copy:
         local_file: " images/ios.bin'"
         remote_file: 'cXXXX-adventerprisek9sna.bin'
         platform: 'cisco_ios_ssh'
         username: admin
         password: "P@55w0rd"
         secret: "5ecretP@55"
         host: "{{ inventory_hostname }}"

    - name: Reload CISCO device to apply new patch
      ios_command:
         commands:
           - "reload in 5\ny"
         platform: 'cisco_ios_ssh'
         username: admin
         password: "P@55w0rd"
         secret: "5ecretP@55"
         host: "{{ inventory_hostname }}"
```
## Use case 2: Adding new configuration into network devices

```
---
- name:  Patch CISCO network devices 
  hosts: ciscoswitches
  become: yes
  become_method: enable
  ansible_connection: network_cli
  ansible_ssh_pass=admin
  ansible_become_pass=”P@55w0rd”
  ansible_network_os=ios
  strategy: debug
  connection: ssh
  serial: 1
  gather_facts: yes
  tasks:
    - name: Update network device hostname to match the one used in the inventory
       ios_config:
          authorize: yes
          lines: ['hostname {{ inventory_hostname }}'] 
          force: yes

    - name: Change the CISCO devices login banner
       ios_config:
          authorize: yes
          lines:
             - banner motd ^This device is controlled via Ansible. Please refrain from doing any manual modification^

    - name: upgrade SSh service to version2
       ios_config:
          authorize: yes
          lines:
             - ip ssh version 2

    - name: Configure VTP to use transparent mode
       ios_config:
          authorize: yes
          lines:
             - vtp mode transparent

    - name: Change DNS servers to point to the Google DNS
       ios_config:
          authorize: yes
          lines:
             - ip name-server 8.8.8.8
             - ip name-server 8.8.4.4

    - name: Configure some realisable NTP servers
       ios_config:
          authorize: yes
          lines:
             - ntp server time.nist.gov
             - ntp server 0.uk.pool.ntp.org
```
