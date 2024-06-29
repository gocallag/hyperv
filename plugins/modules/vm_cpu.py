#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html


DOCUMENTATION = r'''
---
module: vm_cpu
short_description: Manages VHD disk attached to VM
description:
    - Manage the VHD disk on a Hyper-V Virtual Machine
options:
  id:
    description:
      - VMId of VM
    require: true
  count: 
    description:
      - Number of vcpu's to attach
  state:

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