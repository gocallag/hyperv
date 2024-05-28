
#!powershell
# Modelled in https://github.com/ansible-collections/ansible.windows/blob/main/plugins/modules/win_copy.ps1
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>
# Copyright: (c) 2017, Ansible Project


#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$result = @{
    changed = $false
}

$params = Parse-Args -arguments $args -supports_check_mode $false
$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true

Try {

    $vswitch = Get-VMSwitch -name $name -ErrorAction SilentlyContinue | ConvertTo-Json -Compress
    if ($vswitch -ne $null) {
      $result.cmd="$vswitch"
      $result.changed = $true
     } else {
      $result.changed = $false
    }
}
Catch {
    Fail-Json -obj $result -message "an error occurred when attempting to Get-VMSwitch -name $name - $($_.Exception.Message)"
}
Finally {
    # Make sure we do any required cleanup in here
}
Exit-Json -obj $result
