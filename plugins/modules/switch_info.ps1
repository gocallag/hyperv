
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
$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true

Try {

    $cmd = "Get-VMSwitch -name $name"
    $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
    $result.cmd=$cmd
    $result.output=$output
}
Catch {
    Fail-Json -obj $result -message "an error occurred when attempting to Get-VMSwitch -name $name - $($_.Exception.Message)"
}
Finally {
    # Make sure we do any required cleanup in here
}
Exit-Json -obj $result
