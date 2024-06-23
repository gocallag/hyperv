#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html


DOCUMENTATION = r'''
---
module: vm
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
  duplicate:
    description:
    - Allow duplicate VM names
    required: false
    default: false
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
  generation:
    description:
      - What generation VM to create? 1 or 2?
    require: false
    default: 1
'''
EXAMPLES = r'''
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

EXAMPLES = '''
'''