#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html


DOCUMENTATION = r'''
---
module: switch_info
short_description: Get the switch information for the specified switch from the hyper-v host
description:
- Get the switch information for the specified switch from the hyper-v host
options:
  name:
    description:
    - The name of the hyper-v switch to collect information about.
    type: str
    required: yes
notes:
- N/A
seealso:
- N/A
author:
- Geoff O'Callaghan (@gocallag)
'''

EXAMPLES = r'''
- name: Get hyperv switch information for switch called LAB
  gocallag.hyperv.switch_info:
    name: LAB
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