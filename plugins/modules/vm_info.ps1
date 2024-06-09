
#!powershell
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2.0

$ErrorActionPreference = "Stop"

$result = @{
  changed = $false
}

$params = Parse-Args -arguments $args -supports_check_mode $false
$name = Get-AnsibleParam -obj $params -name "names" -aliases "filter_names" -type "list" -failifempty $false
$id = Get-AnsibleParam -obj $params -name "id" -type "str" -failifempty $false
$powerstate = Get-AnsibleParam -obj $params -name "power_state"  -type "str" -failifempty $false




$cmd = ""
if ( $null -eq $id ) { 
  if ( $null -eq $powerstate ) {
    # No power states so it's a simple select-object with Name
    if ( $null -ne $name ) {
      $vmnames = $($name -join ',')
      $cmd = "Get-VM -Name $vmnames | Select-Object *"
    }
    else {
      Fail-Json -obj $result -message "Either name, power_states or id needs to be supplied"
    }
  }
  else {
    if ( $null -ne $name ) {
      $vmnames = $($name -join ',')
      $cmd = @'
      Get-VM -Name $vmnames | Where {$_.State -like 
'@ 
      $cmd += "'$powerstate' } | Select-Object *"
    }
    else {
      $cmd = @'
      Get-VM  | Where {$_.State -like 
'@ 
      $cmd += "'$powerstate' } | Select-Object *"
    }
  }
}
else {
  # A supplied ID overrides all other parameters.
  $cmd = "Get-VM -Id $id | Select-Object *"
}

Try {

  $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
  $result.cmd = $cmd
  $result.output = $output | ConvertTo-Json | ConvertFrom-Json  # note this has to be done otherwise we will hang in Exit-Json
}
Catch {
  Fail-Json -obj $result -message "an error occurred when attempting to Get-VM - $($_.Exception.Message)"
}
Finally {
  # Make sure we do any required cleanup in here
}
Exit-Json -obj $result
