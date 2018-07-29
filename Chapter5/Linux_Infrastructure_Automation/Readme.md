# Linux Infrastructure Automation

## System Management Automation

```
# Use case1: system update automation 
---
- name: Update and clean up Linux OS 
  hosts: Linux
  become: yes
  become_user: setup
  gather_facts: yes
  tasks:
    - name: Update Debian Linux packages with Index updated
      apt: 
           upgrade: dist
           update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Update Red Hat Linux packages with Index updated
      yum: 
           name: "*"
           state: latest
           update_cache: yes
      when: ansible_os_family == "RedHat"

    - name: Clean up Debian Linux from cache and unused packages
      apt: 
           autoremove: yes 
           autoclean: yes
      when: ansible_os_family == "Debian"

    - name: Clean up Red Hat Linux from cache and unused packages
      shell: yum clean all; yum autoremove
      when: ansible_os_family == "RedHat"
     ignore_errors: yes

   - name: Check if Debian system requires a reboot
     shell: "[ -f /var/run/reboot-required ]"
     failed_when: False
     register: reboot_required
     changed_when: reboot_required.rc == 0
     notify: reboot
    when: ansible_os_family == "Debian"
    ignore_errors: yes

   - name: Check if Red Hat system requires a reboot
     shell: "[ $(rpm -q kernel|tail -n 1) != kernel-$(uname -r) ]"
     failed_when: False
     register: reboot_required
     changed_when: reboot_required.rc == 0
     notify: reboot
     when: ansible_os_family == "RedHat" 
     ignore_errors: yes

  handlers:
   - name: reboot
     command: shutdown -r 1 "A system reboot triggered after and Ansible automated system update"
     async: 0
     poll: 0
     ignore_errors: true

---
- name: Update and clean up Linux OS 
  hosts: Linux
  max_fail_percentage: 20
  serial: 5
  become: yes
  become_user: setup
  gather_facts: yes
  tasks:
…

# Use case 2: 





