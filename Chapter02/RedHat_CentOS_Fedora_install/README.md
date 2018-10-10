# Red Hat, CentOS and Fedora package installation

## Install Ansible on Red hat and CentOS

```
cd /tmp
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -i epel-release-latest-7.noarch.rpm
sudo yum update
sudo yum install -y ansible
```

## Install Ansible on Fedora 22 onward

```
cd /tmp
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -i epel-release-latest-7.noarch.rpm
sudo dnf -y update
sudo dnf install -y ansible
```

## Build Ansible rpm file from source
```
cd /tmp
sudo yum install -y git make
git clone https://github.com/ansible/ansible.git
cd ansible
make rpm
sudo rpm -Uvh rpm-build/ansible-*.noarch.rpm
```

