# Ansible Windows Modules

## Windows System Modules
```
# win_user (win_group) module
---
- name: Linux Module running
  hosts: winservers
  gather_facts: false
  tasks:
    - name: create a new group dev
      win_group:
         name: developers
         description: Development department group
         state: present

    - name: create a new user in the dev group
      win_user:
         name: winuser1
         password: Ju5t@n0th3rP@55w0rd
         state: present
         groups:
             - developers

# win_regedit module
    - name: disable Windows auto-update
      win_regedit:
         path: HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
         name: NoAutoUpdate
         data: 1
         type: binary

# win_service module
    - name: disable Windows update service
      win_service:
         name: wuauserv
         state: stopped
         start_mode: disabled

# win_update (win_hotfix, win_features) modules
    - name: install updates for Windows related applications and tools
      win_updates:
         category_names: 
             - Applications
             - Tools
         state: installed
         reboot: no
      become: yes
      become_user: SYSTEM
     
    - name: install a specific Windows Hotfix
      win_hotfix:
         hotfix_kb: KB4088786 
         source: C:\hotfixes\windows10.0-kb4088786-x64_7e3897394a48d5a915b7fbf59ed451be4b07077c.msu
         state: present

    - name: enable Hyper-V and Write Filter features
      win_feature:
         name: 
             - Hyper-V
             - Unified-Write-Filter
         state: present

# win_path module
    - name: enable the VNC port on the host local firewall
      win_firewall_rule:
         name: VNC
         localport: 5900
         protocol: udp
         direction: in
         action: allow
         state: present
         enabled: yes
```
## Windows Package Modules
```
# win_chocolatey module
    - name: setup the latest version of firefox
      win_chocolatey:
         name: firefox
         state: latest

    - name: update all chocolatey installed tools
      win_chocolatey:
         name: all
         state: latest

    - name: remove 7zip
      win_chocolatey:
         name: 7zip
         state: absent

# win_package module
    - name: install atom editor on Windows hosts
      win_package:
         path: C:\app\atom.msi
         arguments: /install /norestart
         state: present

# win-shell (win_command) modules
    - name: run a PowerShell script on a working directory
      win_shell: C:\scripts\PSscript.ps1
         args:
            chdir: C:\Users\winuser1\Workspace
            
    - name: execute a PowerShell command on remote Windows hosts
      win_command: (get-service wuauserv | select status | Format-Wide | Out-String).trim()
      register: output

    - debug: var=output.stdout

# win-scheduled_task module
    - name: schedule running a PowerShell script a specific time
      win_scheduled_task: 
         name: PowerShellscript
         description: Run a script at a specific time
         actions:
         - path: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe 
           arguments: -ExecutionPolicy Unrestricted -NonInteractive -File
         triggers:
         - type: logon
        state: present
        enabled: yes

```
## Windows File Modules
```
# win_file module
    - name: add a new file
      win_file: 
          path: C:\scripts\PSscript2.ps1
         state: touch

    - name: remove a folder
      win_file: 
          path: C:\scripts\TestScripts
         state: absent

# win_share module
    - name: add a new file
      win_share:
          name: devscript
          description: Developers scripts shared folder 
          path: C:\scripts
         list: yes
         full: developers
         read: devops
         deny: marketing

# win_lineinfile module
    - name: copy a file from one location to other within the Windows hosts
      win_copy: 
          src: C:\scripts\PSscript.ps1
         dest: C:\applications\PSscript.ps1
         remote_src: yes

    - name: backup scripts folder 
      win_copy: 
          src: C:\scripts\
         dest: D:\backup\scripts
         recurse: yes

    - name: backup scripts folder 
      win_get_url: 
          url: https://www.github.com/scripts/winscript2.ps1
         dest: C:\scripts\ winscript2.ps1

```
