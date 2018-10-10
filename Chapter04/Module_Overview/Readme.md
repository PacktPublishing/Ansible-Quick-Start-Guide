# Ansible Modules Overview

## Ansible local documentation
```
# print a module documentation
ansible-doc apt

# print the list of the available modules
ansible-doc -l
```

## Ping module Ad-Hoc vs Playbook
```
# Ad-Hoc
ansible servers -m ping 

# Playbook
---
- name: Ping module playbook usage
  hosts: servers
  gather_facts: false
  tasks:
    - name: ping the local servers
      ping:
```
## Win_reboot module Ad-Hoc vs Playbook
```
# Ad-Hoc
ansible winservers -m win_reboot 
ansible winservers -m win_reboot –args="msg='Reboot initiated by remote admin' pre_reboot_delay=5

# Playbook
---
- name: Reboot Windows hosts
  hosts: winservers
  fast_gathering: false
  tasks:
    - name: restart Windows hosts with default settings
      win_reboot:

    - name: restart Windows hosts with personalized settings
      win_reboot:
        msg: "Reboot initiated by remote admin"
        pre_reboot_delay: 5
```
## Copy module Ad-Hoc vs Playbook
```
# Ad-Hoc
ansible servers -m copy --args="src=./file1.txt dest=~/file1.txt"

# Playbook
---
- name: copy a file to hosts
  hosts: servers
  become: true
  fast_gathering: false
  tasks:
    - name: copy a file to the home directory of a user
      copy:
         src: ./file1.txt
         dest: ~/file1.txt
         owner: setup
         mode: 0766
```
# Ansible Return Values
```
# using return values with handlers
---
- name: Restart Linux hosts if reboot is required after updates
  hosts: servers
  gather_facts: false
  tasks:
    - name: check for updates
      become: yes
      become_method: sudo
      apt: update_cache=yes

    - name: apply updates
      become: yes
      become_method: sudo
      apt: upgrade=yes

    - name: check if reboot is required
      become: yes
      become_method: sudo
      shell: "[ -f /var/run/reboot-required ]"
      failed_when: False
      register: reboot_required
      changed_when: reboot_required.rc == 0
      notify: reboot

  handlers:
    - name: reboot
      command: shutdown -r now "Ansible triggered reboot after system updated"
      async: 0
      poll: 0
      ignore_errors: true
      
# plotting a return value using debugger
    - name: apply updates
      become: yes
      become_method: sudo
      apt: upgrade=yes
      register: output

    - name: print system update status return value
      debug: 
           var: output.changed
```
