# Ansible Network Modules
```
# net_get (network_put) modules
---
- name: Network Module running
  hosts: ciscosw
  tasks:
    - name: backup a running configuration for a cisco switch
      net_get: 
          src: running_cfg_{{ inventory_hostname }}.txt

# ios_command module
- name: check on the switch network interfaces status
      ios_command: 
          commands: show interfaces brief
          wait_for: result[0] contains Loopback0

# ios_config module
- name: change switch host name to match the one set in the inventory
      ios_config: 
          lines: hostname {{ inventory_hostname }}

- name: change IP helper config for dhcp requesst sent into the device
      ios_config: 
          lines: ip helper-address 192.168.10.1

# ios_interface module
- name: configure a gigabit interface and make ready to use
      ios_interface: 
          name: GigabitEthernet0/1
          description: lab-network-link
          duplex: full
          speed: 1000
          mtu: 9000
          enabled: True
          state: up

# ios_static_route module
- name: setup a static route on CISCO switches
      ios_static_route: 
          prefix: 192.168.11.0
          mask: 255.255.255.0
          next_hop: 192.168.10.1
          state: present

# ios_vlan module
- name: Add new lab VLAN
      ios_vlan: 
          vlan_id: 45
          name: lab-vlan
          state: presnet

- name: Add network interface to the lab VLAN
      ios_vlan: 
          vlan_id: 45
          interfaces:
             - GigabitEthernet0/1
             - GigabitEthernet0/2

```
