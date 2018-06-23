# Source GitHub or Tar balls  installation

```
# Download and unarchive Ansible source tar ball
wget -c https://releases.ansible.com/ansible/ansible-2.6.0rc3.tar.gz
tar -xzvf  ./ansible-2.6.0rc3.tar.gz
# Install Git on Red Hat
sudo yum install -y git
# Install Git on Debian
sudo apt install -y git
# Install Git on Mac OS X
brew install git
# Clone Ansible GitHub project
git clone https://github.com/ansible/ansible.git --recursive
# Build Ansible from source
cd ./ansible*
sudo easy_install pip
sudo pip install -r ./requirements.txt
source ./hacking/env-setup
# Upgrade Ansible
git pull --rebase
git submodule update --init --recursive
echo "export ANSIBLE_HOSTS=~/ansible_hosts" >> ~/.bashrc
echo "source ~/ansible/hacking/env-setup" >> ~/.bashrc
```
