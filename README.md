Red Hat CodeReady Containers Role w/hacks
=========

Use Ansible to deploy Red Hat CodeReady Containers with HACKS

CodeReady Containers brings a minimal, preconfigured OpenShift 4.1 or newer cluster to your local laptop or desktop computer for development and testing purposes. CodeReady Containers is delivered as a Red Hat Enterprise Linux virtual machine that supports native hypervisors for Linux, macOS, and Windows 10.

Requirements
------------

*  Ansible 
*  Fedora or RHEL 8.x
* IF using RHEL make sure it is registered
* OpenShift CodeReady WorkSpaces  pull secret 
  * https://cloud.redhat.com/openshift/install/crc/installer-provisioned
* Anisble post fix module
  * `ansible-galaxy collection install ansible.posix`

**GET SHA** 
```
$ curl -OL https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/sha256sum.txt
$ cat sha256sum.txt | grep crc-linux-amd64.tar.xz | awk '{print $1}'
```

Inspriation 
--------------
[Accessing CodeReady Containers on a Remote Server](https://www.openshift.com/blog/accessing-codeready-containers-on-a-remote-server/) by Jason Dobies  
[Overview: running crc on a remote server](https://gist.github.com/tmckayus/8e843f90c44ac841d0673434c7de0c6a) by [Trevor McKay](https://gist.github.com/tmckayus)  
[Deploy Bare-Metal Clusters with CRC](https://gist.github.com/v1k0d3n/9ceec7589b5bab0b61b85c2a1e1c463c) by Brandon B. Jozsa

Features
--------
* CodeReady Containers Remote Server Access

Role Variables
--------------

Type  | Description  | Default Value
--|---|--
crc_version  | Target CRC version  | latest
crc_sha      | SHA informaqtion of the crc-linux-amd64.tar.xz file | 179a5f41ce875859a403f79ce0fd1917701bc4c4fbc12a776e5078876dd07743
crc_url      |  CRC download URL | https://mirror.openshift.com/pub/openshift-v4/clients/crc/
crc_file_name  | CRC filename  | crc-linux-amd64.tar.xz
pull_secret_path | default path of pull secret | /tmp/pull-secert.txt
pull_secret_content: | pull secret content     |  changeme
use_all_in_one_haproxy | Use current machine as haproxy LB | true
haproxy_ip             | Set ha proxy ip if above is set to flase **NOT TESTED**| ""
use_all_in_one_dnsmasq | Use current machine as dnsmasq server | true
log_level              | Change log level of crc start command | info
crc_ip_address | Default CRC ip address| 192.168.130.11
ocp4_release  | OCP release folder for cli | latest
ocp4_version   | OCP cli version | latest
ocp4_release_url | OCP release url | "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/{{ ocp4_release }}/"
ocp4_client | OCP cli filename | "openshift-client-linux-{{ ocp4_version }}.tar.gz"
remove_oc_tool | remove oc cli  | false
delete_crc_deployment | delete CodeReady Containers deployment  | false
forward_server | Server to manage external requests | 1.1.1.1

Dependencies
------------
**Home drive should have 50 Gig or better**

**On RHEL 8.x**
* Register system
* Follow system requirements from the code ready containers documentation 

**On Fedora**
* Follow system requirements from the code ready containers documentation 
* enable and start sshd

Prerequiestes
-------------
Configure sudo user 
```
curl -OL https://gist.githubusercontent.com/tosin2013/385054f345ff7129df6167631156fa2a/raw/b67866c8d0ec220c393ea83d2c7056f33c472e65/configure-sudo-user.sh
chmod +x configure-sudo-user.sh
./configure-sudo-user.sh
```

Configure RHEL 8.x  system
```
sudo su - sudouser
curl -OL https://gist.githubusercontent.com/tosin2013/ae925297c1a257a1b9ac8157bcc81f31/raw/142d8dd142b031d59c14a7a7ad6f3000ad775453/configure-rhel8.x.sh
chmod +x configure-rhel8.x.sh
./configure-rhel8.x.sh
```

Optional: Configure Fedora system
```
sudo su - sudouser
curl -OL https://gist.githubusercontent.com/tosin2013/a2af69a0814b38ddf3d98cf8ac5fcf0d/raw/5aed9e7f4a407d8767fe449b763ab8cf11984468/configure-fedora.sh
chmod +x configure-fedora.sh
./configure-fedora.sh
```

Example Playbook
----------------
To run playbook as sudo add the `-K` flag 
Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:
You can get pull secert [here](https://cloud.redhat.com/openshift/install/pull-secret).
```
- hosts: servers
  become: yes
  vars:
    crc_version: latest
    crc_sha: 659046b3e478ef89563babef59c1cacdefe91ed32e844bac4504dba68e4a9f88
    pull_secert_path: /tmp/pull-secert.txt
    pull_secert_content: |
      changeme
    use_all_in_one_haproxy: true
    haproxy_ip: ""
    use_all_in_one_dnsmasq: true 
    log_level: info
    ocp4_release: latest
    ocp4_version: 4.7.16
    remove_oc_tool: false
    delete_crc_deployment: false
    forward_server: 1.1.1.1
  roles:
  - codeready-containers-hacks
```

Deployment Flags
---------------
**Start a full deployment**
```
ansible-playbook  -i inventory deploy-crc.yml --tags download_crc,extract_crc,configure_oc_cli,setup_crc,start_crc_deployment,configure_dnsmaq,configure_ha_proxy -K
```

Manual steps
------------
**Download and install CRC**
```
ansible-playbook  -i inventory deploy-crc.yml --tags download_crc,extract_crc  -K
```


**Configure OpenShift cli**
```
ansible-playbook  -i inventory deploy-crc.yml --tags configure_oc_cli -K
```

**Setup crc and start deployment**
```
ansible-playbook  -i inventory deploy-crc.yml --tags setup_crc,start_crc_deployment  -K
```

**Configure dnsmasq**
```
ansible-playbook  -i inventory deploy-crc.yml --tags configure_dnsmaq  -K
```

**Configure HAPROXY**
```
ansible-playbook  -i inventory deploy-crc.yml --tags configure_ha_proxy  -K
```

**Get crc url and login info**
```
ansible-playbook  -i inventory deploy-crc.yml --tags get_codeready_info
```

**Delete deployment**
```
ansible-playbook  -i inventory deploy-crc.yml --extra-vars "delete_crc_deployment=true" -K 
```

Post Steps
---------
**Configure DNS for external access**  
Option 1: Add a custom zone to your dns
`Example using bind or named`
```
;
; BIND data file for local loopback interface
;
$TTL	604800
$ORIGIN testing.
@	IN	SOA	ns.testing. admin.testing. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	testing.
@	IN	A	127.0.0.1
@	IN	AAAA	::1
@   IN  A   192.168.1.2
ns1			IN	A	192.168.1.2

api.crc.testing.                                                IN      A       192.168.1.10
assisted-service-assisted-installer.apps-crc.testing.           IN      A       192.168.1.10
oauth-openshift.apps-crc.testing.                               IN      A       192.168.1.10
console-openshift-console.apps-crc.testing.                     IN      A       192.168.1.10
*.apps-crc.testing.                                             IN      A       192.168.1.10
```

Option 2: Add the following to your hosts file to access crc remotly
`change 192.168.1.10 to your ip`
```
192.168.1.10 console-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing api.crc.testing
```

**Install ODF-Nano on CRC**  
*  [ODF-Nano](https://github.com/ksingh7/odf-nano)  lets you deploy OpenShift Data Foundation on CRC

Debug info
----------
* During setup the new CodeReady Containers release tasks
  * `tail -f /tmp/crc_setup.log`
  * or `tail -f  tail -f ~/.crc/crc.log`
* Validate configs on crc 
```
$ crc config view
- consent-telemetry                     : yes
- cpus                                  : 8
- memory                                : 96000
- nameserver                            : 1.1.1.1

```

To-Do
-------
* develop against MacOS
* test against RHEL 7
* develop for windows
* test using external dns and haproxy 
* develop against other OS's
* add cpu and memory custom sizing options 
* delete deployment
  
License
-------

GPL-3.0

Author Information
------------------

* Tosin Akinosho - [tosin2013](https://github.com/tosin2013)
