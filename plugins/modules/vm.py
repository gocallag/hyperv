#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# This file is inspired by the way the professionals do it at https://github.com/ansible-collections/ansible.windows/blob/main/plugins/modules/win_acl.py
DOCUMENTATION = '''
---
module: hyperv_vm
short_description: Create/Delete Hyper-V based Virtual Machines.
description:
    - Create/Delete Hyper-V based Virtual Machines.
options:
  name:
    description:
      - Name of VM
    require: true
  state:
    description:
      - State of VM
    require: false
    choices:
      - present
      - absent
    default: null
  VHDPath:
    description:
      - Specify path of VHD/VHDX file for the new VM. If the file already exists then it will be attached to the VM, if not then a new one will be created with size VHDSize
      - If no VHDPath is specified then the VM is created with -NoVHD
    require: false
    default: null
  VHDSize:
    description:
      - Specify the size of any new VHDX file 
    require: false
    default: null
  memory:
    description:
      - Memory for VM
    require: false
    default: null
'''

EXAMPLES = '''
'''
