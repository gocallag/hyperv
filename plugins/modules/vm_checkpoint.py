#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html


DOCUMENTATION = r'''
---
module: vm_checkpoint
short_description: Manage Hyper-V Virtual Machine Checkpoints.
description:
    - Create and remove checkpoints (snapshots) on Hyper-V Virtual Machines.
options:
  vm_name:
    description:
      - Name of the Virtual Machine.
    required: true
    type: str
  name:
    description:
      - Name of the checkpoint / snapshot.
      - Required when state is present.
    required: false
    type: str
    default: null
  checkpoint_type:
    description:
      - The type of checkpoint to configure on the VM.
    required: false
    type: str
    choices:
      - Standard
      - Production
      - ProductionOnly
    default: Production
  state:
    description:
      - Desired state of the checkpoint.
      - C(present) creates a checkpoint if one with the given name does not already exist.
      - C(absent) removes the checkpoint with the given name.
    required: false
    type: str
    choices:
      - present
      - absent
    default: present
'''

EXAMPLES = r'''
- name: Create a standard checkpoint
  gocallag.hyperv.vm_checkpoint:
    vm_name: MyVM
    name: pre-upgrade
    checkpoint_type: Standard
    state: present

- name: Create a production checkpoint
  gocallag.hyperv.vm_checkpoint:
    vm_name: MyVM
    name: pre-upgrade
    checkpoint_type: Production
    state: present

- name: Remove a checkpoint
  gocallag.hyperv.vm_checkpoint:
    vm_name: MyVM
    name: pre-upgrade
    state: absent
'''

RETURN = r'''
pre_cmd:
  description: the powershell command executed on the Hyper-V Host to perform the pre change check
  returned: always
  type: str
pre_output:
  description: the raw output of the powershell command executed as part of the pre change check
  returned: always
  type: str
cmd:
  description: the powershell command executed on the Hyper-V Host
  returned: always
  type: str
output:
  description: the raw output of the powershell command executed
  returned: always
  type: str
changed:
  description: if the resource was changed
  returned: always
  type: boolean
'''
