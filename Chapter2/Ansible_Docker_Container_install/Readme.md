# Ansible Docker container installation

## Ansible Dockerfile
```
FROM alpine:3.7

RUN 	echo “#### Setting up the environment for the build dependencies ####” && \
set -x &&
	apk --update add --virtual build-dependencies \
      	gcc musl-dev libffi-dev openssl-dev python-dev

RUN	echo “#### Update the OS package index and tools ####” && \
apk update && apk upgrade

RUN	echo “#### Setting up the build dependecies ####” && \
apk add --no-cache bash curl tar openssh-client \
sshpass git python py-boto py-dateutil py-httplib2 \
py-jinja2 py-paramiko py-pip py-yaml ca-certificates

RUN	echo “#### Installing Python PyPI ####” && \
pip install pip==9.0.3 && \
pip install python-keyczar docker-py

RUN	echo “#### Installing Ansible latest release and cleaning up ####” && \
pip install ansible –upgrade \
apk del build-dependencies && \
rm -rf /var/cache/apk/*

RUN	echo “#### Initializing Ansible inventory with the localhost ####” && \
mkdir -p /etc/ansible/library /etc/ansible/roles /etc/ansible/lib /etc/ansible/ && \
echo "localhost" >> /etc/ansible/hosts

ENV HOME 			/home/ansible
ENV PATH 			/etc/ansible/bin:$PATH
ENV PYTHONPATH		/etc/ansible/lib
ENV ANSIBLE_ROLES_PATH 	/etc/ansible /roles
ENV ANSIBLE_LIBRARY 	/etc/ansible/library
ENV ANSIBLE_SSH_PIPELINING 		True
ENV ANSIBLE_GATHERING 			smart
ENV ANSIBLE_HOST_KEY_CHECKING 		false
ENV ANSIBLE_RETRY_FILES_ENABLED 	false

RUN 	useradd --create-home --home-dir $HOME ansible && \
chown -R ansible:ansible $HOME

RUN 	echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
	&& chmod 0440 /etc/sudoers

WORKDIR $HOME
USER ansible

ENTRYPOINT ["ansible"]
```

## Building the Ansible container
```
docker build -t dockerhub-user/ansible .
```
## Running Ansible container example
```
docker run --rm -it -v ~:/home/ansible dockerhub-user/ansible --version
```

## Running a ping using ansibel container
```
docker run --rm -it -v ~:/home/ansible \
-v ~/.ssh/id_rsa:/ansible/.ssh/id_rsa \
-v ~/.ssh/id_rsa.pub:/ansible/.ssh/id_rsa.pub \
 	dockerhub-user/ansible -m ping 192.168.1.10
```
## Making script to run Ansible-playbook container
```
#!/bin/bash
docker run --rm -it -v ~:/home/ansible \
-v ~/.ssh/id_rsa:/ansible/.ssh/id_rsa \
-v ~/.ssh/id_rsa.pub:/ansible/.ssh/id_rsa.pub \
-v /var/log/ansible/ansible.log \
 	dockerhub-user/ansible “$@”
```
## Ansibleplaybook usage
```
Ansibleplaybook play tasks.yml -i inventory/hosts 
```



