#!powershell
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2.0
Function Delete_VirtualMachine {
  $pre_cmd = "Get-VM -name '$name'"
  $currentvm = invoke-expression -Command "$pre_cmd -ErrorAction SilentlyContinue"
  $result.pre_cmd = $pre_cmd
  $result.pre_output = $currentvm
    
  if ($null -ne $currentvm) {
    $cmd = "Remove-VM -Name $name -Force"
    $output = invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"
    $result.cmd = $cmd
    $result.output = $output
    $result.changed = $true

  }
  else {
    $result.changed = $false
  }
}

Function Create_VirtualMachine {
  $cmd = "New-VM -Name '$name'"

  if ($memory) {
    $cmd = $cmd + " -MemoryStartupBytes $memory"
  }

  if ($null -ne $VHDPath) {
    if (Test-Path $VHDPath) {
      if ( $null -ne $VHDSize ) {
        Fail-Json $result "VHDPath already exists, but we've specified a size to create a new VHDX file"
      }
      else {
        $cmd = $cmd + " -VHDPath $VHDPath"
      }
    }
    if ($null -ne $VHDPATH -and $VHDSize) {
      $cmd = $cmd + " -NewVHDPath $newVHDPath -NewVHDSizeBytes $newVHDSize"
    }
    else {
      Fail-Json $result "diskPath does not exist and no diskSize was supplied!"
    }
  }
  else {
    $cmd = $cmd + " -NoVHD "
  }

  if ($generation) {
    $cmd = $cmd + " -Generation $generation"
  }


  $result.cmd = $cmd
  $result.changed = $true
    
  invoke-expression -Command "$cmd -ErrorAction SilentlyContinue"  # note: saving the output of this IE leads to an infinite loop [BUG] somewhere
  
}




$params = Parse-Args $args -supports_check_mode $false
$result = @{
  changed = $false
  cmd     = ""
}


$name = Get-AnsibleParam $params "name" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: name"
$state = Get-AnsibleParam $params "state" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: state"
$memory = Get-AnsibleParam $params "memory" -type "str" -Default $null
$generation = Get-AnsibleParam $params "generation" -type "int" -Default "1"
$VHDPath = Get-AnsibleParam $params "VHDPath" -type "str" -Default $null
$VHDSize = Get-AnsibleParam $params "VHDSize" -type "str"  -Default $null



switch ($state) {
  "present" {
    Create_VirtualMachine
  }
  "absent" {
    Delete_VirtualMachine
  }
}

Exit-Json $result;
