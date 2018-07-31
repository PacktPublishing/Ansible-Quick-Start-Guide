# Windows Infrastructure Automation

## System management Automation

### Use case 1: System update automation

```
---
- name:  Windows updates management
  hosts: windows
  become: yes
  gather_facts: yes
  tasks:
   - name: Create the registry path for Windows Updates
     win_regedit:
       path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
       state: present
     ignore_errors: yes

   - name: Add register key to disable Windows AutoUpdate
     win_regedit:
       path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
       name: NoAutoUpdate
       data: 1
       type: dword
     ignore_errors: yes

    - name: Make sure that the Windows update service is running
      win_service:
        name: wuauserv
        start_mode: auto
        state: started
      ignore_errors: yes

    - name: Executing Windows Updates on selected categories
      win_updates:
        category_names:
          - Connectors
          - SecurityUpdates
          - CriticalUpdates
          - UpdateRollups
          - DefinitionUpdates
          - FeaturePacks
          - Application
          - ServicePacks
          - Tools
          - Updates
          - Guidance
        state: installed
        reboot: yes
      become: yes
      become_method: runas
      become_user: SYSTEM
      ignore_errors: yes
      register: update_result

    - name: Restart Windows hosts in case of update failure 
      win_reboot:
      when: update_result.failed

```
### Use case 2: Automated Windows optimisation

```
---
- name:  Windows system configuration and optimisation
  hosts: windows
  become: yes
  gather_facts: yes
  vars:
    macaddress: "{{ (ansible_interfaces|first).macaddress|default(mac|default('')) }}"
  tasks:
   - name: Send magic Wake-On-Lan packet to turn on individual systems
     win_wakeonlan:
       mac: '{{ macaddress }}'
       broadcast: 192.168.11.255

   - name: Wait for the host to start it WinRM service
     wait_for_connection:
       timeout: 20

   - name: start a defragmentation of the C drive
     win_defrag:
       include_volumes: C
       freespace_consolidation: yes

   - name: Setup some registry optimization
     win_regedit:
       path: '{{ item.path }}'
       name: '{{ item.name }}'
       data: '{{ item.data|default(None) }}'
       type: '{{ item.type|default("dword") }}'
       state: '{{ item.state|default("present") }}'
     with_items:
     
    # Set primary keyboard layout to English (UK)
    - path: HKU:\.DEFAULT\Keyboard Layout\Preload
      name: '1'
      data: 00000809
      type: string

    # Show files extensions on Explorer
    - path: HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
      name: HideFileExt
      data: 0

    # Make files and folders search faster on the explorer
    - path: HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
      name: Start_SearchFiles
      data: 1

  - name: Add Windows hosts to local domain
    win_domain_membership:
      hostname: '{{ inventory_hostname_short }}'
      dns_domain_name: lab.edu
      domain_ou_path: lab.edu
      domain_admin_user: 'admin'
      domain_admin_password: '@dm1nP@55'
      state: domain
```
## Application and services Automation

### Use case 1: Automate Windows application management 

```
---
- name:  Application management on Windows hosts
  hosts: windows
  become: yes
  gather_facts: yes
  tasks:
   - name: Install latest updated PowerShell for optimised Chocolatey commands
     win_chocolatey:
       name: powershell
       state: latest

   - name: Update Chocolatey to its latest version
     win_chocolatey:
       name: chocolatey
       state: latest

   - name: Install a list of applications via Chocolatey
     win_chocolatey:
       name: {{ item }}
       state: latest
     with_items:
         - javaruntime
         - flashplayeractivex
         - 7zip
         - firefox
         - googlechrome
         - atom
         - notepadplusplus
         - vlc
         - adblockplus-firefox
         - adblockplus-chrome
         - adobereader
      Ignore_errors: yes
```
### Use case 2: Setup NSclient Nagios client

```
---
- name:  Setup Nagios agent on Windows hosts
  hosts: windows
  become: yes
  gather_facts: yes
  tasks:
   - name: Copy the MSI file for the NSClient to the windows host
     win_copy:
       src:  ~/win_apps/NSCP-0.5.0.62-x64.msi
       dest: C:\NSCP-0.5.0.62-x64.msi

   - name: Install an NSClient with the appropriate arguments
     win_msi:
       path: C:\NSCP-0.5.0.62-x64.msi
       extra_args: ADDLOCAL=FirewallConfig,LuaScript,DotNetPluginSupport,Documentation,CheckPlugins,NRPEPlugins,NSCPlugins,NSCAPlugin,PythonScript,ExtraClientPlugin,SampleScripts ALLOWED_HOSTS=127.0.0.1,192.168.10.10 CONF_NSCLIENT=1 CONF_NRPE=1 CONF_NSCA=1 CONF_CHECKS=1 CONF_NSCLIENT=1 CONF_SCHEDULER=1 CONF_CAN_CHANGE=1 MONITORING_TOOL=none NSCLIENT_PWD=”N@g10sP@55w0rd”
        wait: true

   - name: Copying NSClient personalised configuration file
     win_copy:
       src: ~/win_apps/conf_files/nsclient.ini
       dest: C:\Program Files\NSClient++\nsclient.ini

   - name: Change execution policy to allow the NSClient script remote Nagios execution
     raw: Start-Process powershell -verb RunAs -ArgumentList 'Set-ExecutionPolicy RemoteSigned -Force'

   - name: Restart the NSclient service to apply the configuration change
     win_service:
       name: nscp
       start_mode: auto
       state: restarted

   - name: Delete the MSI file
     win_file: path=C:\NSCP-0.5.0.62-x64.msi state=absent
```
