# Ansible Cloud Modules
## VMware Modules
```
# inventory file
---
[vms:vars]
datacenter: "vcenter.lab.edu"
vcenter_hostname: "vcenter.lab.edu"
vcenter_username: "admin"
vcenter_password: "@dm1np@55w0rd"


[vms]
vm0
vm1
vm2

[esxi_hostname]
esxihost1	  esxihost1.lab.edu
esxihost2	  esxihost2.lab.edu


# install python library for vmware management
pip install pyvmomi

# vmware_guest (vsphere_guest) module
---
- name: VMware Module running
  hosts: vms
  tasks:
    - name: create a new virtual machine from template
      vmware_guest:
          hostname: "{{ vcenter_hostname }}"
          username: "{{ vcenter_username }}"
          password: "{{ vcenter_password }}"
          validate_certs: False
          folder: /lab-folder
          name: "{{ inventory_hostname }}"
          state: poweredon
          template: debian8_temp
          disk:
          - size_gb: 15
            type: thin
            datastore: labdatastore1
          hardware:
            memory_mb: 1024
            num_cpus: 2
            num_cpu_cores_per_socket: 2
            scsi: paravirtual
            max_connections: 5
            hotadd_cpu: True
            hotremove_cpu: True
            hotadd_memory: True
            hotremove_memory: True
            version: 11 
          cdrom:
            type: iso
            iso_path: "[ labdatastore1] /iso_folder/debian8.iso"
          networks:
          - name: Lab Network
          wait_for_ip_address: yes
       delegate_to: localhost

# vmware_guest_snapshot module
    - name: create a virtual machine snapshot
      vmware_guest_snapshot:
          hostname: "{{ vcenter_hostname }}"
          username: "{{ vcenter_username }}"
          password: "{{ vcenter_password }}"
          datacentre: vcenter.lab.edu
          validate_certs: False
          folder: /lab-folder
          name: "{{ inventory_hostname }}"
          state: present 
          snapshot_name: Post_Fixes
          description: Fixes_done_on_vm
      delegate_to: localhost

# vmware_vm_shell module
    - name: run a command on a running virtual machine
      vmware_guest_snapshot:
          hostname: "{{ vcenter_hostname }}"
          username: "{{ vcenter_username }}"
          password: "{{ vcenter_password }}"
          datacentre: vcenter.lab.edu
          validate_certs: False
          folder: /lab-folder
          vm_id: "{{ inventory_hostname }}"
          vm_username: setup 
          vm_password: "@P@55w0rd"
          vm_shell: /bin/service 
          vm_shell_args: networking restart
      delegate_to: localhost


# vmware_host_powerstate module
    - name: restart ESXi host
      vmware_guest_snapshot:
          hostname: "{{ vcenter_hostname }}"
          username: "{{ vcenter_username }}"
          password: "{{ vcenter_password }}"
          validate_certs: no
          esxi_hostname: esxihost1.lab.edu
          state: reboot-host
      delegate_to: localhost

```
## Docker Modules
```
# requirements
pip install 'docker-py>=1.7.0'
pip install 'docker-compose>=1.7.0'

# docker_container module
---
- name: Docker Module running
  hosts: local
  tasks:
    - name: create a container
      docker_container:
          name: debianlinux
          image: debian:9
          pull: yes
          state: present

    - name: start a container
      docker_container:
          name: debianlinux
          state: started
          devices:
            - "/dev/sda:/dev/xvda:rwm"
          
    - name: stop a container
       docker_container:
          name: debianlinux
          state: stopped

# docker_image module
     - name: pull a container image
       docker_image:
          name: ubuntu:18.04
          pull: yes

     - name: push a container image to docker hub
       docker_image:
          name: labimages/ubuntu
          repository: labimages/ubuntu
          tag: lab18
          push: yes

     - name: remove a container image
       docker_image:
          name: labimages/ubuntu
          state: absent
          tag: lab16

# docker_login module
     - name: login to DockerHub 
       docker_login:
          username: labuser1
          password: "L@bp@55w0rd"
          email: user1@lab.edu

```
## Amazon AWS Modules
```
# requirements
pip install boto

---
ec2_access_key: "a_key"
ec2_secret_key: "another_key"

# ec2 module
---
- name: AWS Module running
  hosts: localhost
  gather_facts: False
  tasks:
    - name: create a new AWS EC2 instance
      ec2:
          key_name: ansible_key
          instance_type: t2.micro
          image: ami-6b3fd60c
          wait: yes
          group: labservers
          count: 2
          vpc_subnet_id: subnet-3ba41052
          assign_public_ip: yes

# ec2_ami module
    - name: register an AWS AMI image
      ec2_ami:
          instance_id: i-6b3fd61c
          wait: yes
          name: labami
          tags:
             Name: LabortoryImage
             Service: LabScripts

# ec2_key module
    - name: create an EC@ key pair
      ec2_key:
          name: ansible2-key
          key_material: "{{ lookup('file', '/home/admin/.ssh/id_rsa') }}"
          state: present
```
