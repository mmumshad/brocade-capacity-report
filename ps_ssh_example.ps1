﻿##
# vElemental.com -  @clintonskitson
# 01/10/12
# ps_ssh_example.ps1 - an example of how to leverage SSH with Powershell
#
##

$spath = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\ssh_function.ps1"
. $spath

function cust_sleep {
param($sleep)
    1..($sleep) | %{
        sleep 1
        if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character)) { 
            [console]::TreatControlCAsInput = $false
            Remove-SshSession
            write "Exiting cleanly and closing SSH session"
            exit 
        }  
    }
}

function execp_ssh ($tmpCmd) {
    $tmpCmd=$tmpCmd.replace('"','\"')
    send-ssh ('cmd="'+$tmpCmd+'"')
    [array]$tmpOut = invoke-ssh "$tmpCmd;$expectCmd" $expect
    $tmpStartLine = $tmpOut | select-string -pattern ";$expectCmd" | %{ $_.linenumber } | select -last 1
    $tmpEndLine = ($tmpOut | select-string -pattern $expect | %{ $_.linenumber } | select -first 1) - 2
    if(!$tmpStartLine) { $tmpStartLine = 0 }
    if(!$tmpEndLine) { $tmpEndLine = $tmpOut.count-1 }
    $tmpOut[($tmpStartLine)..($tmpEndLine)]
}
