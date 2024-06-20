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
$order = Get-AnsibleParam $params "order" -type "list" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: order"

$pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
$currentvm = invoke-expression -Command "$pre_cmd "
$result.pre_cmd = $pre_cmd
$result.pre_output = $currentvm | ConvertTo-Json | ConvertFrom-Json

  
if ($null -ne $currentvm ) {
  if ( $currentvm.State -eq "Off" ) {
    $vm = $(GET-VM -Id "$vmid")  
    if ($vm.Generation -eq 1) {
      # For a Gen 1 VM, the boot order is a simplistic list of devices, no validation of the names is performed
      $bootorder = ''
      foreach ($c in $order) {
        if ( $bootorder -eq '' ) {
          $bootorder += "'$c'"
        }
        else {
          $bootorder += ",'$c'"
        }
      }
      $cmd = @'
     Set-VMBios -VM $vm -StartupOrder @(
'@ + $bootorder + ')'
      $output = invoke-expression -Command "$cmd"
      $result.cmd = $cmd
      $result.output = $output | ConvertTo-Json | ConvertFrom-Json
      $result.changed = $true
    }
    elseif ( $vm.Generation -eq 2) {
      $bootorder = ''
      foreach ($c in $order) {
        $boottype = $c -split ':'
        switch ($boottype[0]) {
          "NETWORK" {
            $vm = $(GET-VM -Id $vm.Id)
            $nwboot = $(GET-VMNetworkAdapter -VM $vm -Name $boottype[1]) 
            if ($bootorder -eq "") {
              $bootorder += @'
                    $nwboot
'@
            }
            else {
              $bootorder += @'
              , $nwboot
'@
            }
          }
          "DISK" {
            $vm = $(GET-VM -Id $vm.Id)
            $diskboot = $(GET-VMHardDiskDrive -VM $vm -Name $boottype[1]) 
            if ($bootorder -eq "") {
              $bootorder += @'
                    $diskboot
'@
            }
            else {
              $bootorder += @'
              , $diskboot
'@
            }
          }
          Default { Fail-Json $result "Unknown boot type $boottype[0]" }
        }
      }
      $cmd = @'
     Set-VMFirmware -VM $vm -BootOrder
'@ + $bootorder

      $output = invoke-expression -Command "$cmd"
      $result.cmd = $cmd
      $result.output = $output | ConvertTo-Json | ConvertFrom-Json
      $result.changed = $true
    }
    else {
      Fail-Json $result "VM $vmid has unknown generation $vm.Generation "
    }
  }
  else {
    $result.changed = $false
    Fail-Json $result "VM $vmid needs to be powered off to set boot order"
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
