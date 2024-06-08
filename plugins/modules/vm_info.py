#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html


DOCUMENTATION = r'''
---
module: vm_info
short_description: Get the VM information for the specified VM from the hyper-v host
description:
- Get the VM information for the specified VM from the hyper-v host
options:
  name:
    description:
    - The name of the hyper-v VM(s) to collect information about.
    type: str
    required: no
  name:
    description:
    - The name of the hyper-v VM to collect information about.
    type: str
    required: no
notes:
- N/A
seealso:
- N/A
author:
- Geoff O'Callaghan (@gocallag)
'''

EXAMPLES = r'''
- name: Get hyperv VM information for VM called LAB-Test
  gocallag.hyperv.vm_info:
    name: LAB-Test
  register: info

- name: Print out the results
  debug:
    msg: "{{ info }}"
'''

RETURN = r'''
cmd:
  description: the powershell command executed on the Hyper-V Host
  returned: always
  type: str
output:
  description: the raw output of the powershell command executed
  returned: always
  type: str
changed:
  description: if the resource was changed - always false
  returned: always
  type: boolean
'''