# Ansible Container
## Ansible Container usage
```
# Install ansible-container with two containers engines
pip install ansible-container[docker,k8s]

# Create Ansible container project file
ansible-container init

# List of files that gets created in a Ansible container project
ansible.cfg
ansible-requirements.txt
container.yml
meta.yml
requirements.yml
.dockerignore

# Build a contaienr images
ansible-container build

# Update a container image at a time
ansible-container run

# Upload and apply Ansible orchestration on container images
ansible-container deploy
```
## Sample Ansible container
```
# Create Container folder and init files
mkdir /home/admin/Containers/webserver
cd /home/admin/Containers/webserver
ansible-container init

# Content of container.yml file
version: '2'
settings:
  conductor:
    base: 'ubuntu:xenial'
  project_name: webserver

services:
  web:
    from: centos:7
    command: [nginx]
    entrypoint: [/usr/bin/entrypoint.sh]
    ports:
      - 80:80
    roles:
      - nginx-server

# Content of meta.yml file
galaxy_info:
   author: alibi
   description: A generic webserver
   licence: GPL3

   galaxy_tags:
        - container
        - webserver
        - nginx
# Content of requirement.yml file
nginx-server

# Build the contaienr project
ansible-container build
```
