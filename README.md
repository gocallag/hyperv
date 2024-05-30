# Ansible Collection - gocallag.hyperv

Documentation for the collection.

```
---
  - hosts: weed01
    tasks:
      - name: Create switch LAB-Test that is bridged to Adapter "Ethernet"
        gocallag.hyperv.hyperv_switch:
          name: LAB-Test
          netAdapterName: "Ethernet"
          switchType: External
          state: present
        register: output
      - name: test hyperv_switch_info
        gocallag.hyperv.hyperv_switch_info:
          name: LAB-Test
        register: output
      - debug: msg="{{ output }}"

      - name: Delete switch
        gocallag.hyperv.hyperv_switch:
          name: LAB-Test
          state: absent
        register: output

      - name: Create switch LAB-Test of switchType Internal
        gocallag.hyperv.hyperv_switch:
          name: LAB-Test
          switchType: Internal
          state: present
        register: output
      - name: test hyperv_switch_info
        gocallag.hyperv.hyperv_switch_info:
          name: LAB-Test
        register: output
      - debug: msg="{{ output }}"

      - name: Delete switch
        gocallag.hyperv.hyperv_switch:
          name: LAB-Test
          state: absent
        register: output

      - name: Create switch LAB-Test of switchType Private
        gocallag.hyperv.hyperv_switch:
          name: LAB-Test
          switchType: Private
          state: present
        register: output
      - name: test hyperv_switch_info
        gocallag.hyperv.hyperv_switch_info:
          name: LAB-Test
        register: output
      - debug: msg="{{ output }}"

      - name: Delete switch
        gocallag.hyperv.hyperv_switch:
          name: LAB-Test
          state: absent
        register: output
```