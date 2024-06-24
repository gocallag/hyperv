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

# Add-VMHardDiskDrive
#    [-VM] <VirtualMachine[]>
#    [[-ControllerType] <ControllerType>]
#    [[-ControllerNumber] <Int32>]
#    [[-ControllerLocation] <Int32>]
#    [[-Path] <String>]
#    [-DiskNumber <UInt32>]
#    [-ResourcePoolName <String>]
#    [-SupportPersistentReservations]
#    [-AllowUnverifiedPaths]
#    [-MaximumIOPS <UInt64>]
#    [-MinimumIOPS <UInt64>]
#    [-QoSPolicyID <String>]
#    [-QoSPolicy <CimInstance>]
#    [-Passthru]
#    [-OverrideCacheAttributes <CacheAttributes>]
#    [-WhatIf]
#    [-Confirm]
#    [<CommonParameters>]
  
if ($null -ne $currentvm ) {
  if ( $currentvm.State -eq "Off" ) {
    if ($state -eq "present") {
      # Get-VMHardDiskDrive
      #  [-VM] <VirtualMachine[]>
      #  [-ControllerLocation <Int32>]
      #  [-ControllerNumber <Int32>]
      #  [-ControllerType <ControllerType>]
      #  [<CommonParameters>]
      $vm = $(GET-VM -Id "$vmid") 
      $cmd = @'
        Get-VMHardDiskDrive -VM $vm | Where-Object { $_.Path -eq $path}
'@
      $output = invoke-expression -Command "$cmd"
      if ($null -eq $output) { # disk already exists
        $cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
        $currentvm = invoke-expression -Command "$pre_cmd "
        $result.output = $currentvm | ConvertTo-Json | ConvertFrom-Json
        $vm = $(GET-VM -Id "$vmid") 
        $cmd = @'
            Add-VMHardDiskDrive -VM $vm 
'@+ "-Path $path"
        $output = invoke-expression -Command "$cmd"
        $result.cmd = $cmd
        $result.changed = $true
      } else {
        $result.changed = $false
      }
      $cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
      $currentvm = invoke-expression -Command "$pre_cmd "
      $result.output = $currentvm | ConvertTo-Json | ConvertFrom-Json
    }
    elseif ( $state -eq "absent") {
      $vm = $(GET-VM -Id "$vmid") 
      $cloc = ""
      $cnum = ""
      foreach ($d in $vm.HardDrives) {
        if ($d.Path -eq $path) {
          $cloc = $d.ControllerType
          $cnum = $d.ControllerNumber
        }
      }
      # Get-VMHardDiskDrive -VMName TestVM -ControllerType IDE -ControllerNumber 1 | Remove-VMHardDiskDrive
      $cmd = @'
            Get-VMHardDiskDrive -VM $vm 
'@+ " -ControllerType $cloc -ControllerNumber $cnum | Remove-VMHardDiskDrive"
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
    Fail-Json $result "VM $vmid needs to be powered off to manage disk drive"
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
