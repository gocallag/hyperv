#!powershell
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2.0
Function PowerOn_VirtualMachine {
  $pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
  $currentvm = invoke-expression -Command "$pre_cmd "
  $result.pre_cmd = $pre_cmd
  $result.pre_output = $currentvm | ConvertTo-Json | ConvertFrom-Json
  
    
  if ($null -ne $currentvm -and $currentvm.State -eq "Off" ) {
    $vm = $(GET-VM -Id "$vmid")  # Get the VM object as we need it for the start-vm. This will work as we checked in the pre-command
    $cmd = @'
            Start-VM -VM $vm
'@
    $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
    $result.cmd = $cmd
    $result.output = $output | ConvertTo-Json | ConvertFrom-Json
    $result.changed = $true

  }
  elseif ($null -ne $currentvm) {
    $result.changed = $false
    Fail-Json $result "No VM with VMId $vmid"
  }
  else {
    $result.changed = $false
  }
}

Function PowerOff_VirtualMachine {

  Param
  (
       [Parameter(Mandatory=$true, Position=0)]
       [string] $mode
  )
  $pre_cmd = "GET-VM -Id '$vmid' -ErrorAction SilentlyContinue | select-object *"
  $currentvm = invoke-expression -Command "$pre_cmd "
  $result.pre_cmd = $pre_cmd
  $result.pre_output = $currentvm | ConvertTo-Json | ConvertFrom-Json
  $cmd = @'
  Stop-VM -VM $vm
'@
  if ( $mode -eq "turnoff" ) {
    $cmd = @'
    Stop-VM -VM $vm -TurnOff
'@
  }
  if ( $mode -eq "forceoff" ) {
    $cmd = @'
    Stop-VM -VM $vm -Force
'@
  }
      
  if ($null -ne $currentvm -and $currentvm.State -eq "Running" ) {
    $vm = $(GET-VM -Id "$vmid")  # Get the VM object as we need it for the start-vm. This will work as we checked in the pre-command

    $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
    $result.cmd = $cmd
    $result.output = $output | ConvertTo-Json | ConvertFrom-Json
    $result.changed = $true

  }
  elseif ($null -ne $currentvm) {
    $result.changed = $false
    Fail-Json $result "No VM with VMId $vmid"
  }
  else {
    $result.changed = $false
  }
}




$params = Parse-Args $args -supports_check_mode $false
$result = @{
  changed = $false
  cmd     = ""
}


$vmid = Get-AnsibleParam $params "id" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: id"
$state = Get-AnsibleParam $params "state" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: state"
switch ($state) {
  "on" {
    PowerOn_VirtualMachine
  }
  { ($_ -eq "off") -or ($_ -eq "turnoff") -or ($_ -eq "forceoff" ) } {
    PowerOff_VirtualMachine $state
  }
}

Exit-Json $result;
