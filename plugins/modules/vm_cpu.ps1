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
$count = Get-AnsibleParam $params "count" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: count"

$pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
$currentvm = invoke-expression -Command "$pre_cmd "

# Set-VMProcessor
#    [-VM] <VirtualMachine[]>
#    [-Count <Int64>]
#    [-CompatibilityForMigrationEnabled <Boolean>]
#    [-CompatibilityForOlderOperatingSystemsEnabled <Boolean>]
#    [-HwThreadCountPerCore <Int64>]
#    [-Maximum <Int64>]
#    [-Reserve <Int64>]
#    [-RelativeWeight <Int32>]
#    [-MaximumCountPerNumaNode <Int32>]
#    [-MaximumCountPerNumaSocket <Int32>]
#    [-ResourcePoolName <String>]
#    [-EnableHostResourceProtection <Boolean>]
#    [-ExposeVirtualizationExtensions <Boolean>]
#    [-Passthru]
#    [-WhatIf]
#    [-Confirm]
#    [<CommonParameters>]
  
if ($null -ne $currentvm ) {
  if ( $currentvm.State -eq "Off" ) {
    $vm = $(GET-VM -Id "$vmid") 
    $cmd = @'
        Set-VMProcessor -VM $vm 
'@+ '-Count $count'
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
