# Ansible Roles

## What are Ansible Roles

### Tasks folder
```
tasks/main.yml:
---
    - name: check if NTP is installed
      stat:  
          path: /etc/init.d/ntpd
      register: tool_status

    - include_tasks: debian.yml 
      when: tool_status.stat.exisits

    - name: Copy the NTP config to remote host 
      template: 
          src: /template/ntp.conf.j2
          dest: /etc/ntpd/ntpd.conf
          mode: 0400
      notify: 
           - Restart ntp

tasks/debian.yml:
---
    - name: Copy a NTP config to remote host 
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
          name: ntpd
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
…

server {{ ntpserv1 }}
server {{ ntpserv2 }}

…
```
### Defaults folder
```
vars/main.yml:
---
defaults/main.yml:
---
timout: 2000
ID_key: "None"
```
### Meta folder
```
meta/main.yml:
---
dependencies:
   - role: named
     vars:
         DNS1: 8.8.8.8
         DNS2: 8.8.4.4
```
