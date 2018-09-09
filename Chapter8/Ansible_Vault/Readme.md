# Ansible Vault

## Ansible Vault usage
```
# Create a vault file
ansible-vault create /home/admin/Vault/vault.yml

# Select text editor while creating a vault file
export EDITOR=nano; ansible-vault create /home/admin/Vault/vault.yml

# Show how a vault file looks like when opend with a normal text reader
cat /home/admin/Vault/vault.yml

# Edit a vault file
ansible-vault edit /home/admin/Vault/vault.yml

# View in plain text the content of a vault file
ansible-vault view /home/admin/Vault/vault.yml

# Change a vault file password
ansible-vault rekey /home/admin/Vault/vault.yml

# Convert a normal text file to vault file
ansible-vault encrypt /home/admin/variables.yml

# Convert a vault file to normal text file
ansible-vault decrypt /home/admin/variables.yml
```
## Ansible Vault playbooks usage best practices
```
# Use prompt to enter vault password
ansible-playbook playbook.yml --ask-vault-pass 

# Use password file to enter vault password
ansible-playbook playbook.yml --vault-password-file /home/admin/.secrets/vault_pass.txt

# Make vault password persistent  
nano /etc/ansible/ansible.cfg

[default]
...
vault_password_file = /home/admin/.secrets/vault_pass.txt

# Edit vautl file to put in a sensative variable
ansible-vault edit /home/admin/vault.yml

# Sample playbook for vault variabel usage
...
  include_vars: /home/admin/vault.yml
  tasks:
     name: connect to a web service 
     shell: servicex -user user1 -password "{{ vault_user_pass }}"
...

# Execution of the playbook with vault password file pointed out
ansible-playbook service_connect.yml --vault-password-file /home/admi/.vault

# Install Cryptography package 
pip install cryptography
```
