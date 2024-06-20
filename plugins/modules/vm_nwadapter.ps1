#!powershell
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2.0

$params = Parse-Args $args -supports_check_mode $false
$result = @{
  changed = $false
  cmd     = ""
}


$vmid = Get-AnsibleParam $params "id" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: id"
$name = Get-AnsibleParam $params "name" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: name"
$swname = Get-AnsibleParam $params "switch" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: switch"
$state = Get-AnsibleParam $params "state" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: state"

$pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
$currentvm = invoke-expression -Command "$pre_cmd "

# Add-VMNetworkAdapter
#    [-SwitchName <String>]
#    [-IsLegacy <Boolean>]
#    [-Name <String>]
#    [-DynamicMacAddress]
#    [-StaticMacAddress <String>]
#    [-Passthru]
#    [-ResourcePoolName <String>]
#    [-VM] <VirtualMachine[]>
#    [-DeviceNaming <OnOffState>]
#    [-WhatIf]
#    [-Confirm]
#    [<CommonParameters>]
  
if ($null -ne $currentvm ) {
  if ( $currentvm.State -eq "Off" ) {
    if ($state -eq "present") {
      $vm = $(GET-VM -Id "$vmid") 
      $cmd = @'
            Add-VMNetworkAdapter -VM $vm 
'@+ "-Name $name -SwitchName $swname"
      $output = invoke-expression -Command "$cmd"
      $result.cmd = $cmd
      $cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
      $currentvm = invoke-expression -Command "$pre_cmd "
      $result.output = $currentvm | ConvertTo-Json | ConvertFrom-Json
    }
    elseif ( $state -eq "absent") {
      $vm = $(GET-VM -Id "$vmid") 
      $found = $false
      foreach ($d in $vm.NetworkAdapters) {
        if ($d.Name -eq $name) {
          $found = $true
        }
      }
      if ( $found -eq $true) {
        $cmd = @'
            Remove-VMNetworkAdapter -VM $vm 
'@+ " -Name $name"
        $output = invoke-expression -Command "$cmd"
        $result.cmd = $cmd
        $result.output = $output | ConvertTo-Json | ConvertFrom-Json
        $result.changed = $true
      }
      else {
        Fail-Json $result "Could not find network adapter named $name"
      }

    }
    else {
      $result.changed = $false
      Fail-Json $result "state needs to be present or absent"
    }
  }
  else {
    $result.changed = $false
    Fail-Json $result "VM $vmid needs to be powered off to manage Network Adapter"
  }

}
elseif ($null -ne $currentvm) {
  $result.changed = $false
  Fail-Json $result "No VM with VMId $vmid"
}
else {
  $result.changed = $false
}
Exit-Json $result;
