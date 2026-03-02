#!powershell
# Re-worked based on best practices at https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general_windows.html
# Copyright: (c) 2024, Geoff O'Callaghan <geoffocallaghan@gmail.com>

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2.0

Function Create_Checkpoint {
  # Check VM exists
  $pre_cmd = "Get-VM -Name '$vm_name' -ErrorAction SilentlyContinue | Select-Object *"
  $currentvm = Invoke-Expression -Command "$pre_cmd"
  $result.pre_cmd = $pre_cmd
  $result.pre_output = $currentvm | ConvertTo-Json | ConvertFrom-Json

  if ($null -eq $currentvm) {
    $result.changed = $false
    Fail-Json $result "No VM with name '$vm_name'"
  }

  # Set the checkpoint type on the VM
  $cmd_type = "Set-VM -Name '$vm_name' -CheckpointType $checkpoint_type"
  Invoke-Expression -Command "$cmd_type -ErrorAction SilentlyContinue"

  # Check if checkpoint with the given name already exists
  if ($null -ne $checkpoint_name -and $checkpoint_name -ne "") {
    $existing = Get-VMSnapshot -VMName $vm_name -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $checkpoint_name }
    if ($null -ne $existing) {
      $result.changed = $false
      $result.output = $existing | ConvertTo-Json | ConvertFrom-Json
      return
    }
    $cmd = "Checkpoint-VM -Name '$vm_name' -SnapshotName '$checkpoint_name'"
  }
  else {
    $cmd = "Checkpoint-VM -Name '$vm_name'"
  }

  $output = Invoke-Expression -Command "$cmd -ErrorAction SilentlyContinue"
  $result.cmd = $cmd
  $result.output = $output | ConvertTo-Json | ConvertFrom-Json
  $result.changed = $true
}

Function Delete_Checkpoint {
  # Check VM exists
  $pre_cmd = "Get-VM -Name '$vm_name' -ErrorAction SilentlyContinue | Select-Object *"
  $currentvm = Invoke-Expression -Command "$pre_cmd"
  $result.pre_cmd = $pre_cmd
  $result.pre_output = $currentvm | ConvertTo-Json | ConvertFrom-Json

  if ($null -eq $currentvm) {
    $result.changed = $false
    Fail-Json $result "No VM with name '$vm_name'"
  }

  if ($null -eq $checkpoint_name -or $checkpoint_name -eq "") {
    Fail-Json $result "Checkpoint name is required when state is absent"
  }

  $existing = Get-VMSnapshot -VMName $vm_name -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $checkpoint_name }
  if ($null -ne $existing) {
    $cmd = "Remove-VMSnapshot -VMName '$vm_name' -Name '$checkpoint_name'"
    $output = Invoke-Expression -Command "$cmd -ErrorAction SilentlyContinue"
    $result.cmd = $cmd
    $result.output = $output | ConvertTo-Json | ConvertFrom-Json
    $result.changed = $true
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

$vm_name = Get-AnsibleParam $params "vm_name" -type "str" -FailIfEmpty $true -emptyattributefailmessage "missing required argument: vm_name"
$checkpoint_name = Get-AnsibleParam $params "name" -type "str" -Default $null
$checkpoint_type = Get-AnsibleParam $params "checkpoint_type" -type "str" -Default "Production" -ValidateSet "Standard", "Production", "ProductionOnly"
$state = Get-AnsibleParam $params "state" -type "str" -Default "present" -ValidateSet "present", "absent"

switch ($state) {
  "present" {
    Create_Checkpoint
  }
  "absent" {
    Delete_Checkpoint
  }
}

Exit-Json $result;
