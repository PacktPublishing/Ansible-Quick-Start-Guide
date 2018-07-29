# Linux Infrastructure Automation

## System Management Automation

### Use case 1: system update automation 

```
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

# A way to accomodate redendency system
---
- name: Update and clean up Linux OS 
  hosts: Linux
  max_fail_percentage: 20
  serial: 5
  become: yes
  become_user: setup
  gather_facts: yes
  tasks: ...

```

### Use case 2: Creating a new user with all its settings

```
---
- name: Create a dedicated remote management user 
  hosts: Linux
  become: yes
  become_user: setup
  gather_facts: yes
  tasks:
    - name: Create a now basic user
      user: 
         name: 'ansuser'   
         password: $6$C2rcmXJPhMAxLLEM$N.XOWkuukX7Rms7QlvclhWIOz6.MoQd/jekgWRgDaDH5oU2OexNtRYPTWwQ2lcFRYYevM83wIqrK76sgnVqOX. 
         # A hash for generic password.
         Append: yes
         groups: sudo
         shell: /bin/bash
         state: present

    - name: Create the user folder to host the SSH key
      file: 
         path: /home/ansuser/.ssh
         state: directory
         mode: 0700
         owner: ansuser

    - name: Copy server public SSH key to the newly created folder
      copy: 
         src: /home/admin/.ssh/ansible_rsa
         dest: /home/ansuser/.ssh/id_rsa
         mode: 0600
         owner: ansuser

    - name: Configure the sudo group to work without password
      lineinfile: 
         dest: /etc/sudoers
         regexp: '^%sudo\s'
         line: "%sudo ALL=(ALL) NOPASSWD{{':'}} ALL" 
         validate: 'visudo -cf %s'
         state: present

    - name: Install favourite text editor for Debian family
      apt: 
         name: nano
         state: latest
         update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Install favourite text editor for Red Hat family
      yum: 
         name: nano
         state: latest
      when: ansible_os_family == "RedHat"

    - name: remove old editor configuration file
      file: 
         path: /home/ansuser/.selected_editor
         state: absent
      ignore_errors: yes

    - name: Create a new configuration file with favourite text editor
      lineinfile: 
         dest: /home/ansuser/.selected_editor
         line: "SELECTED_EDITOR='/usr/bin/nano'" 
         state: present
         create: yes

    - name: Make the user a system user to hide it from login interface
      blockinfile: 
         path: /var/lib/AccountsService/users/ansuser
         state: present
         create: yes
         block: |
             [User]
             SystemAccount=true

# Create a a SHA512 password
mkpasswd --method=sha-512

```

### use case 3: Automated services management

```
