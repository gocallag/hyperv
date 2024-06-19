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
$path = Get-AnsibleParam $params "path" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: path"
$state = Get-AnsibleParam $params "state" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: state"

$pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
$currentvm = invoke-expression -Command "$pre_cmd "


  
if ($null -ne $currentvm ) {
  if ( $currentvm.State -eq "Off" ) {
    if ($state -eq "present") {
      $vm = $(GET-VM -Id "$vmid") 
      $cmd = @'
            Add-VMDvdDrive -VM $vm 
'@+ "-Path $path"
      $output = invoke-expression -Command "$cmd"
      $result.cmd = $cmd
      $cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-sobject *"
      $currentvm = invoke-expression -Command "$pre_cmd "
      $result.output = $currentvm | ConvertTo-Json | ConvertFrom-Json
    }
    elseif ( $state -eq "absent") {
      $vm = $(GET-VM -Id "$vmid") 
      $cloc = ""
      $cnum = ""
      foreach ($d in $vm.DvdDrives) {
        if ($d.Path -eq $path) {
          $cloc = $d.ControllerLocation
          $cnum = $d.ControllerNumber
        }
      }
      $cmd = @'
            Get-VMDvdDrive -VM $vm 
'@+ " -ControllerLocation $cloc -ControllerNumber $cnum"
      $output = invoke-expression -Command "$cmd"
      $result.cmd = $cmd
      $result.output = $output | ConvertTo-Json | ConvertFrom-Json
      $result.changed = $true

    }
    else {
      $result.changed = $false
      Fail-Json $result "state needs to be present or absent"
    }
  }
  else {
    $result.changed = $false
    Fail-Json $result "VM $vmid needs to be powered off to manage DVD drive"
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
