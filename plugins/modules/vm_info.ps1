
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

$vmnames = $($name -join ',')

$cmd = ""
if ( $null -ne $vmnames ) {
  $cmd = "Get-VM -Name $vmnames | Select-Object *"
}
if ( $null -ne $id ) {   # id takes precedence
  $cmd = "Get-VM -Id $id | Select-Object *"
}
If ( $null -eq $name -and $null -eq $id ) {
   Fail-Json -obj $result -message "Either name or id needs to be supplied"
}

Try {

    $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
    $result.cmd=$cmd
    $result.output=$output | ConvertTo-Json | ConvertFrom-Json  # note this has to be done otherwise we will hang in Exit-Json
}
Catch {
    Fail-Json -obj $result -message "an error occurred when attempting to Get-VM - $($_.Exception.Message)"
}
Finally {
    # Make sure we do any required cleanup in here
}
Exit-Json -obj $result
