function Start-VSWhere
{
    if (-not (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"))
    {
        Throw "Unable to find 'vswhere.exe'. Is Visual Studio installed?"
    }

    return &"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -prerelease -format json | ConvertFrom-Json
}

# Lists all installed VS instances

<#
.SYNOPSIS
Lists all installed Visual Studio instances.
#>
function Get-VSInstances
{
    $instances = Start-VSWhere

    Write-Host -ForegroundColor Cyan "Installed VS Instances:"
    Write-Host -ForegroundColor Cyan "Enter 0 to not enter a shell."
    $i = 1
    foreach ($instance in $instances)
    {
        $displayName = $instance.displayName
        $installationName = $instance.installationName
        $installationPath = $instance.installationPath
        $nickName = $instance.properties.nickname
        $instanceId = $instance.instanceId

        Write-Host "`n$i): $displayName`n    ->  $installationName`n    ->  $installationPath`n    ->  Nick Name: $nickName`n    ->  Instance Id: $instanceId"

        $i++
    }
    Write-Host -ForegroundColor Cyan "Enter 0 to not enter a shell."
}

function Set-VSShelltarget($instanceId)
{
    if($instanceId -eq 0)
    {
        Write-Host -ForegroundColor Cyan "No instance selected, not loading a dev shell"
        return
    }
    
    $instance = Get-VSInstance $instanceId

    # Set the variable listened to by the patch script so that patch knows which VS to update.
    $env:DevShellTargetPath = $instance.installationPath
      
    Import-Module "$env:DevShellTargetPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell $instance.instanceId
    
    Write-Host "Set DevShell target to: $($instance.instanceId) in $($instance.installationPath)"
}

function Get-VSInstance($instance)
{
    if ([string]::IsNullOrWhiteSpace($instance))
    {
        $instance = 1
    }

    $instances = Start-VSWhere

    if ($instances.Count -lt $instance)
    {
        Throw "Invalid instance number."
    }

    return $instances[$instance - 1]
}

function Set-VSInstanceForShell($instanceId=$null)
{   
    # Set VS instance
    if($null -eq $instanceId)
    {
        Write-Host -ForegroundColor Cyan Choose VS instance to use
        Get-VSInstances
        $instance = Read-Host
        Set-VSShelltarget $instance       
    }
    else{
        Write-Host -ForegroundColor Cyan "Using passed in instance number to start devshell"
        Set-VSShelltarget $instanceId
    }

}

New-Alias -name setdevshell -Value Set-VSInstanceForShell