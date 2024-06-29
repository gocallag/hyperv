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
$maxsize = Get-AnsibleParam $params "maxsize" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: maxsize"
$minsize = Get-AnsibleParam $params "minsize" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: minsize"
$startsize = Get-AnsibleParam $params "startsize" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: startsize"
$buffer = Get-AnsibleParam $params "buffer" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: buffer"
$pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
$currentvm = invoke-expression -Command "$pre_cmd "

# Set-VMMemory
#    [-VM] <VirtualMachine[]>
#    [-Buffer <Int32>]
#    [-DynamicMemoryEnabled <Boolean>]
#    [-MaximumBytes <Int64>]
#    [-StartupBytes <Int64>]
#    [-MinimumBytes <Int64>]
#    [-Priority <Int32>]
#    [-MaximumAmountPerNumaNodeBytes <Int64>]
#    [-ResourcePoolName <String>]
#    [-Passthru]
#    [-WhatIf]
#    [-Confirm]
#    [<CommonParameters>]
  
if ($null -ne $currentvm ) {
  if ( $currentvm.State -eq "Off" ) {
    $vm = $(GET-VM -Id "$vmid") 
    $cmd = @'
        Set-VMMemory -VM $vm -DynamicMemoryEnabled $true 
'@+ " -MinimumBytes $minsize -StartupBytes $startsize -MaximumBytes $maxsize -Buffer $buffer"

    $output = invoke-expression -Command "$cmd"
    $result.changed = $true
  }
  else {
    $result.changed = $false
    Fail-Json $result "VM $vmid needs to be powered off to manage disk drive"
  }
}
else {
  $result.changed = $false
  Fail-Json $result "No VM with VMId $vmid"
}
$cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
$currentvm = invoke-expression -Command "$pre_cmd "
$result.output = $currentvm | ConvertTo-Json | ConvertFrom-Json
Exit-Json $result;
