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



$path = Get-AnsibleParam $params "path" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: path"
$state = Get-AnsibleParam $params "state" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: state"
$size = Get-AnsibleParam $params "size" -type "str" -FailIfEmpty $false

# Get-VHD
#    [-Path] <String[]>
#    [-CimSession <CimSession[]>]
#    [-ComputerName <String[]>]
#    [-Credential <PSCredential[]>]
#    [<CommonParameters>]




if ($state -eq "present") {  
  $cmd = "GET-VHD -Path '$path' -ErrorAction SilentlyContinue | select-object *"
  $currentvhd = invoke-expression -Command "$cmd "
  if ($null -ne $currentvhd ) {
    $result.cmd = $cmd
    $result.output = $currentvhd | ConvertTo-Json | ConvertFrom-Json
    $result.changed = $false
  }
  else {

    #   New-VHD
    #  [-Path] <String[]>
    #  [-SizeBytes] <UInt64>
    #  [-Dynamic]
    #  [-BlockSizeBytes <UInt32>]
    #  [-LogicalSectorSizeBytes <UInt32>]
    #  [-PhysicalSectorSizeBytes <UInt32>]
    #  [-AsJob]
    #  [-CimSession <CimSession[]>]
    #  [-ComputerName <String[]>]
    #  [-Credential <PSCredential[]>]
    #  [-WhatIf]
    #  [-Confirm]
    #  [<CommonParameters>]
    $cmd = "New-VHD -Path '$path' -SizeBytes ${size}GB"
    $currentvhd = invoke-expression -Command "$cmd "
    $result.cmd = $cmd
    $result.output = $currentvhd | ConvertTo-Json | ConvertFrom-Json
    $result.changed = $true
  }
}
elseif ( $state -eq "absent" ) {
  $cmd = "GET-VHD -Path '$path' -ErrorAction SilentlyContinue | select-object *"
  $currentvhd = invoke-expression -Command "$cmd "
  if ($null -eq $currentvhd ) {
    $result.cmd = $cmd
    $result.changed = $false
  }
  else {
    $cmd = "Remove-Item -Path '$path' -ErrorAction SilentlyContinue | select-object *"
    $currentvhd = invoke-expression -Command "$cmd "
    $result.cmd = $cmd
    $result.changed = $true
  }
}



Exit-Json $result;
