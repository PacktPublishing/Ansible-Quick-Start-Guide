# Debian package installation


## Install Ansible using repository using the DEB link
```
echo “deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main” >> /etc/apt/source.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt install -y ansible
```

## Install Ansible using repository using the PPA link
```
sudo apt install -y ansible
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt install -y ansible
```
