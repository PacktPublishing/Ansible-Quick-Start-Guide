# Ansible Galaxy roles management
## Ansible galaxy roles installation
```
# Simple install
ansible-galaxy install geerlingguy.ntp

# Personalised install
ansible-galaxy install geerlingguy.ntp,v1.6.0
ansible-galaxy install git+https://github.com/geerlingguy/ansible-role-ntp.git

# Multi roles installation
ansible-galaxy install -r requirements.yml

# Requirements file sampel structure

# install NTP from Galaxy hub
- src: geerlingguy.ntp

# install Apache from GitHub repo
- src: https://github.com/geerlingguy/ansible-role-apache
  name: apache

# install NFS version 1.2.3 from GitHub
- src: https://github.com/geerlingguy/ansible-role-nfs
  name: nfs4
  version: 1.2.3

- include: ~/role_req/haproxy_req.yml

```
