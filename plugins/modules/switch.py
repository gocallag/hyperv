#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# This file is inspired by the way the professionals do it at https://github.com/ansible-collections/ansible.windows/blob/main/plugins/modules/win_acl.py
DOCUMENTATION = r'''
---
module: hyperv_switch
short_description: Adds, deletes and performs configuration of Hyper-V Virtual Switch.
description:
    - Adds, deletes and performs configuration of Hyper-V Virtual Switch.
options:
  name:
    description:
      - Name of Virtual Switch
    required: true
  state:
    description:
      - State of Virtual Switch
    required: false
    choices:
      - present
      - absent
    default: present
  switchType:
    description:
      - Type of Virtual Switch
    required: false
    choices:
      - Internal
      - Private
      - External
    default: Internal
  netAdapterName:
    description:
      - Name of the physical adapter to be used for the Virtual Switch
    required: true
    default: null
  allowManagementOS:
    description:
      - Specifies whether the parent partition (i.e. the management operating system) is to have access to the physical NIC bound to the virtual switch to be createdName of the physical adapter to be used for the Virtual Switch
    required: false
    default: disabled 
notes:
- Does not support check mode
seealso:
- none
author:
- Geoff O'Callaghan (@gocallag)
'''

EXAMPLES = r'''

'''
