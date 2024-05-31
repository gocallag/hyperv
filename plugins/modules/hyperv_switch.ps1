
#!powershell
# Modelled in https://github.com/ansible-collections/ansible.windows/blob/main/plugins/modules/win_copy.ps1
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>find
#Requires -Module Ansible.ModuleUtils.Legacy

Function Delete_VirtualSwitch {
    $pre_cmd = "Get-VMSwitch -name $name"
    $currentSwitch = invoke-expression -Command "$pre_cmd -ErrorAction SilentlyContinue"
    $result.pre_cmd = $pre_cmd
    $result.pre_output = $currentSwitch
    
    if ($null -ne $currentSwitch) {
      $cmd="Remove-VMSwitch -Name $name -Force"
      $output = invoke-expression -Command "$pre_cmd -ErrorAction SilentlyContinue"
      $result.cmd = $cmd
      $result.output = $output
      $result.changed = $true
      
      $results = invoke-expression $cmd
    } else {
      $result.changed = $false
    }
}
Function Create_VirtualSwitch {
    #Check If the VirtualSwitch already exists
    $pre_cmd = "Get-VMSwitch -name $name"
    $currentSwitch = invoke-expression -Command "$pre_cmd -ErrorAction SilentlyContinue"
    
    if ($null -eq $currentSwitch) {
      # New switch, build up the command to execute
      $cmd = "New-VMSwitch -Name $name"
  
      if ($null -ne $switchType -and $switchType -ne "External" ) {
        $cmd += " -SwitchType $switchType"
      }
      if ($null -ne $netAdapterName -and $switchType -eq "External" ) {
        $cmd += " -NetAdapterName '$netAdapterName'"
      }
      if ($null -ne $netAdapterName -and $null -ne $allowManagementOS) {
        if ($allowManagementOS) {
            $flag = '$true'
            $cmd += " -AllowManagementOS $flag"
        }
        else {
          $flag = '$false'
          $cmd += " -AllowManagementOS $flag"
        }
      }
      
      $result.changed = $true
      $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
      $result.cmd = $cmd
      $result.output = $output
  
    } 
    else {
        $result.changed = $false
    } 
    # Get-VMSwitch and return the data
    $result.pre_cmd = $pre_cmd
    $result.pre_output = $currentSwitch
    
}

$ErrorActionPreference = "Stop"

$result = @{
    changed = $false
}


$params = Parse-Args $args -supports_check_mode $false
$result = @{
  changed = $false
}

$name = Get-AnsibleParam $params "name" -type "str" -FailIfEmpty $true 
$state = Get-AnsibleParam $params "state" -type "str" -FailIfEmpty $true 
$switchType = Get-AnsibleParam $params "switchType" -type "str" -Default $null
$netAdapterName = Get-AnsibleParam $params "netAdapterName" -type "str"  -Default $null
$netAdapterNameDescription = Get-AnsibleParam $params "netAdapterNameDescription" -type "str"  -Default $null
$allowManagementOS = Get-AnsibleParam $params "allowManagementOS" -type "str" -Default $null


switch ($state) {
    "present" {
      if ($null -ne $netAdapterName -and $switchType -ne "External" ) {
        Fail-Json -obj $result -message "switchType External is required with netAdapterName"
      }
      if ($null -eq $netAdapterName -and $null -ne $allowManagementOS ) {
        Fail-Json -obj $result -message "netAdapterName is required with allowManagementOS"
      }
      if ($switchType -eq "External" -and $null -eq $netAdapterName ) {
        Fail-Json -obj $result -message "NetAdapterName is required with switchType External"
      }
      Create_VirtualSwitch
    }
    "absent" {
      Delete_VirtualSwitch
    }
}

Exit-Json -obj $result
