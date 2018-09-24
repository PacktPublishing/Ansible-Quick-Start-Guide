# Linux Infrastructure Automation

## System Management Automation

### Use case 1: system update automation 

```
---
- name: Update and clean up Linux OS 
  hosts: Linux
  become: yes
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
---
- name: Setup and configured recommended Linux services
  hosts: Linux
  become: yes
  gather_facts: yes
  tasks:
    - name: Install a list of services on Linux hosts
      package: 
         name: '{{ item }}'
         state: latest
      with_items:
         - ntp
         - tzdate
         - autofs

    - name: Fix time zone on Red Hat 6
      lineinfile: 
         path: /etc/sysconfig/clock
         line: "ZONE='Europe/London'"
         state: present
         create: yes
      when: ansible_os_family == 'RedHat' and ansible_distribution_version.split('.')[0] == '6'

    - name: Setup time zone on all local hosts
      timezone: 
         name: ''Europe/London”

    - name: Fix time zone on Red Hat 6
      blockinfile:
         path: /etc/ntp.conf
         block: |
            server time.nist.gov iburst
            server 0.uk.pool.ntp.org iburst
            server 1.uk.pool.ntp.org iburst
         insertafter: "# Specify one or more NTP servers."
         state: present

    - name: Restart NTP service to apply change and enable it on Debian
      systemd:
         name: ntp
         enabled: True
         state: restarted
      when: ansible_os_family == 'Debian'

    - name: Restart NTP service to apply change and enable it on Red Hat
      systemd:
         name: ntpd
         enabled: True
         state: restarted
      when: ansible_os_family == RedHat

    - name: Add NFS and SMB support to automount
      blockinfile: 
         path: /etc/auto.master
         block: |
            /nfs       /etc/auto.nfs
            /cifs    /etc/auto.cifs 
         state: present

    - name: create the NFS and SMB AutoFS configuration files
      file: 
         name: '{{ item }}'
         state: present
      with_items:
         - '/etc/auto.nfs'
         - '/etc/auto.cifs'

    - name: Restart AutoFS service to apply change and enable it
      systemd:
         name: autofs
         enabled: True
         state: restarted
```
### Use case 4: Automated network drives mounting (NFS, SMB)

```
---
- name: Setup and connect network shared folders
  hosts: Linux
  become: yes
  gather_facts: yes
  tasks:
    - name: Install the dependencies to enable NFS and SMB clients
      package: 
         name: '{{ item }}'
         state: latest
      with_items:
         - nfs-common
         - nfs-utils
         - rpcbind
         - cifs-utils

    - name: Block none authorised NFS servers using rpcbind
      lineinfile: 
         path: /etc/hosts.deny
         line: "rpcbind: ALL"
         state: present
         create: yes

    - name: Allow the target NFS servers using rpcbind
      lineinfile: 
         path: /etc/hosts.allow
         line: "rpcbind: 192.168.10.20"
         state: present
         create: yes

    - name: Configure NFS share on Fstab
      mount: 
         name: nfs shared
         path: /nfs/shared
         src: "192.168.10.20:/media/shared"
         fstype: nfs
         opts: defaults
        state: present

    - name: Create the shared drive directories
      file:
         name: '{{ item }}'
         state: directory
      with_items:
         - '/nfs/shared'
         - '/cifs/winshared'

    - name: Configure NFS share on AutoFS
      lineinfile: 
         path: /etc/auto.nfs
         line: "shared      -fstype=nfs,rw,      192.168.10.20:/media/shared”
        state: present

    - name: Configure SMB share on AutoFS
      lineinfile: 
         path: /etc/auto.cifs
         line: "winshared      -fstype=cifs,rw,noperm,credentials=/etc/crd.txt      ://192.168.11.20/winshared”
        state: present

    - name: Restart AutoFS service to apply NFS and SMB changes
      systemd:
         name: autofs
         state: restarted
```
### Use case 5: Automate backing up some important documents

```
---
- name: Setup and connect network shared folders
  hosts: Linux
  become: yes
  gather_facts: yes
  tasks:
    - name: Install the dependencies to for archiving the backup
      package: 
         name: '{{ item }}'
         state: latest
      with_items:
         - zip
         - unzip
         - gunzip
         - gzip
         - bzip2
         - rsync

    - name: Backup the client folder to the vault datastore server
      synchronize:
         mode: push 
         src: /home/client1
         dest: client@vault.lab.edu:/media/vault1/client1
         archive: yes
         copy_links: yes
         delete: no
         compress: yes
         recursive: yes
         checksum: yes
         links: yes
         owner: yes
         perms: yes
         times: yes
         set_remote_user: yes
         private_key: /home/admin/users_SSH_Keys/id_rsa
      delegate_to: "{{ inventory_hostname }}"
```
## Applications and services Automation

### Use case 1: Setup a Linux desktop environment with some pre-installed tools
```
---
- name: Setup and connect network shared folders
  hosts: Linux
  become: yes
  gather_facts: yes
  tasks:
    - name: Install OpenBox graphical interface
      apt: 
         name: '{{ item }}'
         state: latest
         update_cache: yes
      with_items:
         - openbox
         - nitrogen
         - pnmixer
         - conky
         - obconf
         - xcompmgr
         - tint2

    - name: Install basic tools for desktop Linux usage and application build
      apt: 
         name: '{{ item }}'
         state: latest
         update_cache: yes
      with_items:
         - htop
         - screen
         - libreoffice-base
         - libreoffice-calc
         - libreoffice-impress
         - libreoffice-writer
         - gnome-tweak-tool
         - firefox
         - thunderbird
         - nautilus
         - build-essential
         - automake
         - autoconf
         - unzip
         - python-pip
         - default-jre
         - cmake
         - git
         - wget
         - cpanminus
         - r-base
         - r-base-core
         - python3-dev

    - name: Install tools using Perl CPAN
      cpanm:
          name: '{{ item }}'
      with_items:
         - Data::Dumper
         - File::Path
         - Cwd

    - name: Install tools using Python PyPip
      pip:
          name: '{{ item }}'
      with_items:
         - numpy 
         - cython
         - scipy
         - biopython

    - name: Install tools on R CRAN using Bioconductor as source 
      shell:  Rscript --vanilla -e "source('https://bioconductor.org/biocLite.R'); biocLite(ask=FALSE); biocLite(c('ggplots2', 'edgeR','optparse'), ask=FALSE);"

    - name: Download a tool to be compiled on each host
      get_url:  
          src: http://cegg.unige.ch/pub/newick-utils-1.6-Linux-x86_64-enabled-extra.tar.gz 
          dest: /usr/local/newick.tar.gz
          mode: 0755

    - name: Unarchive the downloaded tool on each host
      unarchive:  
          url: /usr/local/newick.tar.gz
          dest: /usr/local/
          remote_src: yes
          mode: 0755

    - name: Configure the tool before to the host before building
      command: ./configure chdir="/usr/local/newick-utils-1.6"

    - name: Build the tool on the hosts
      make:
          chdir: /usr/local/newick-utils-1.6
          target: '{{ item }}'
      with_items:
         - check 
         - install

    - name: Create Symlink to the tool’s binary to be executable from anywhere in the system 
      file:  
          path: /usr/local/newick-utils-1.6/src/nw_display
          dest: /usr/local/bin/nw_display
          state: link

    - name: Installing another tool located into a github repo
      git:  
          repo: https://github.com/chrisquince/DESMAN.git
          dest: /usr/local/DESMAN
          clone: yes

    - name: Setup the application using python compiler
      command: python3 ./setup.py install
```
### Use case 2: LAMP server setup and configuration

```
---
- name: Install a LAMP on Linux hosts
  hosts: webservers
  become: yes
  gather_facts: yes
  tasks:
    - name: Install Lamp packages
      apt: 
         name: '{{ item }}'
         state: latest
         update_cache: yes
      with_items:
         - apache2
         - mysql-server
         - php
         - libapache2-mod-php
         - python-mysqldb

    - name: Create the Apache2 web folder
      file: 
         dest: "/var/www"
         state: directory
         mode: 0700
         owner: "www-data"
         group: "www-data"   

    - name: Setup Apache2 modules
      command: a2enmod {{ item }} creates=/etc/apache2/mods-enabled/{{ item }}.load
      with_items:
         - deflate
         - expires
         - headers
         - macro
         - rewrite
         - ssl

    - name: Setup PHP modules
      apt: 
         name: '{{ item }}'
         state: latest
         update_cache: yes
      with_items:
         - php-ssh2
         - php-apcu
         - php-pear
         - php-curl
         - php-gd
         - php-imagick
         - php-mcrypt
         - php-mysql
         - php-json

    - name: Remove MySQL test database
      mysql_db:  db=test state=absent login_user=root login_password="DBp@55w0rd"

    - name: Restart mysql server
      service: 
         name: mysql
         state: restarted

    - name: Restart Apache2
      service: 
         name: apache2
         state: restarted
```
