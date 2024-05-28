#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# This file is inspired by the way the professionals do it at https://github.com/ansible-collections/ansible.windows/blob/main/plugins/modules/win_acl.py
DOCUMENTATION = r'''
---
module: hyperv_switch_info
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
- Does not support check mode
seealso:
- none
author:
- Geoff O'Callaghan (@gocallag)
'''

EXAMPLES = r'''
- name: Get hyperv switch information for LAB 
 hyperv_switch_info:
    name: LAB
  register: info

- name: Print out the results
  debug:
    msg: "{{ info }}"
'''
