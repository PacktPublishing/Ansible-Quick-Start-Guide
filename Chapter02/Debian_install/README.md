# Debian package installation


## Installing Ansible using the DEB repository
```
sudo apt install -y software-properties-common
echo “deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main” >> /etc/apt/source.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt install -y ansible
```

## Installing Ansible using the PPA repository
```
sudo apt install -y software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible
```
