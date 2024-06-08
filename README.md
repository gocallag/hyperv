# Ansible Collection - gocallag.hyperv

[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)


# gocallag.hyperv Collection

This collection provides a range of modules for managing Hyper-V hosts and VM's etc that run on those hosts.

**Note:** This collection is still in active development. There may be unidentified issues and various variables may change as development continues.

## Requirements

### Ansible

- This collection is developed and tested with [maintained](https://docs.ansible.com/ansible/devel/reference_appendices/release_and_maintenance.html) versions of Ansible core (above `2.12`).

## Installation

This collection can be installed via either Ansible Galaxy (the Ansible community marketplace) at (https://galaxy.ansible.com/gocallag/hyper-v) or by cloning this repo. 

### Ansible Galaxy

To install the latest stable release of the collection on your system, use:

```bash
ansible-galaxy collection install gocallag.hyperv
```

Alternatively, if you have already installed the role, you can update the role to the latest release by using:

```bash
ansible-galaxy collection install -f gocallag.hyperv
```

As the collection provides a range of modules you will need to include them as appropriate in your playbook:

```yaml
- name: Create VM
  gocallag.hyperv.vm:
    name: TEST01
```


## Platforms

This collection has been tested against the following Hyper-V configurations

```yaml
Windows Server:
  - 2025 (Preview)
```

## Example Playbooks

Working functional playbook examples can be found in the **[`molecule/`](https://github.com/gocallag/hyperv/blob/main/molecule/)** folder in the following files:

| Name | Description |
| ---- | ----------- |
| **[`create switch`](https://github.com/gocallag/hyperv/blob/main/molecule/switch/converge.yml)** | Create a Hyper-V vswitch |
| **[`delete switch`](https://github.com/gocallag/hyperv/blob/main/molecule/switch/cleanup.yml)** | Delete a Hyper-V vswitch |
| **[`get switch info`](https://github.com/gocallag/hyperv/blob/main/molecule/switch_info/converge.yml)** | Get information about a Hyper-V vswitch |
| **[`create vm`](https://github.com/gocallag/hyperv/blob/main/molecule/vm/converge.yml)** | Create a Hyper-V VM |
| **[`delete vm`](https://github.com/gocallag/hyperv/blob/main/molecule/vm/cleanup.yml)** | Delete a Hyper-V VM |
| **[`get vm info`](https://github.com/gocallag/hyperv/blob/main/molecule/vm_info/converge.yml)** | Get information about a Hyper-V VM |


## License

[Apache License, Version 2.0](https://github.com/nginxinc/ansible-role-nginx/blob/main/LICENSE)

## Author Information

[Geoff O'Callaghan](https://github.com/gocallag)

