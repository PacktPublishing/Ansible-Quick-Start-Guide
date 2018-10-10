# Cloud and virtual Infrastructure Automation 

## VMware automation

### use case 1: 

```
---
- name: Create a virtual machine from a template
  hosts: localhost
  gather_facts: False
  tasks:
    - name: Create a virtual machine
       vmware_guest:
          hostname: 'vcenter.edu.lab'
          username: 'vmadmin@lab.edu'
          password: 'VMp@55w0rd'
          datecenter_name: 'vcenter.edu.lab'
          validate_certs: no
          esxi_hostname: 'esxi1.lab.edu'
          template: ubuntu1404Temp
          folder: '/DeployedVMs'
          name: '{{ item.hostname }}'
          state: poweredon
          disk:
          - size_gb: 50
              type: thin
              datastore: 'datastore1'
          networks:
          - name: 'LabNetwork'
              ip: '{{ item.ip }}'
              netmask: '255.255.255.0'
              gateway: '192.168.13.1'
              dns_servers:
              - '8.8.8.8'
              - '8.8.4.4'
          hardware:
              memory_mb: '1024'
              num_cpus: '2'
          wait_for_ip_address: yes
        delegate_to: localhost
        with_items:
            - { hostname: vm1, ip: 192.168.13.10 }
            - { hostname: vm2, ip: 192.168.13.11 }
            - { hostname: vm3, ip: 192.168.13.12 }

    - name: add newly created VMs to the Ansible inventory
       add_host:
          hostname: "{{ item.hostname }}"
          ansible_host: "{{ item.ip }}"
          ansible_ssh_user: setup
          ansible_ssh_pass: "L1nuxP@55w0rd"
          ansible_connection: ssh
          groupname: Linux
       with_items:
            - { hostname: vm1, ip: 192.168.13.10 }
            - { hostname: vm2, ip: 192.168.13.11 }
            - { hostname: vm3, ip: 192.168.13.12 }
```
### Use case2: ESXi hosts and cluster management

```
---
- name: Create a VMware cluster and populate it
  hosts: localhost
  gather_facts: False
  tasks:
    - name: Create a VMware virtual cluster
      vmware_cluster:
          hostname: 'vcenter.edu.lab'
          username: 'vmadmin@lab.edu'
          password: 'VMp@55w0rd'
          datecenter_name: 'vcenter.edu.lab'
          validate_certs: no
          cluster_name: "LabCluster"
          state: present
          enable_ha: yes  
          enable_drs: yes
          enable_vsan: no  

    - name: Add a VMware ESXi host to the newly created Cluster
      vmware_host:
          hostname: 'vcenter.edu.lab'
          username: 'vmadmin@lab.edu'
          password: 'VMp@55w0rd'
          datecenter_name: 'vcenter.edu.lab'
          validate_certs: no
          cluster_name: " LabCluster "
          esxi_hostname: "esxi1.lab.edu"
          esxi_username: "root"
          esxi_password: "E5X1P@55w0rd"
          state: present
```
