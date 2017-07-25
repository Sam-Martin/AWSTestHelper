﻿Function Get-AWSTestEnvironmentStackOutputs{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$True)]
        [string]$ID,
        [parameter(Mandatory=$True)]
        [string]$Region
    )
    $CFNStack = Get-CFNStack -StackName "PowerShellAWSTestEnvironment-$ID" -Region $Region -ErrorAction SilentlyContinue
    if(!$CFNStack){
        throw "No CFN stack found with the name PowerShellAWSTestEnvironment-$ID"
    }

    return @{
        VPCID = ($CFNStack.Outputs | ?{$_.outputkey -eq "VPCID"}).OutputKey
        PublicSubnetID = ($CFNStack.Outputs | ?{$_.outputkey -eq "PublicSubnetAID"}).OutputKey
        AvailabilityZone = ($CFNStack.Outputs | ?{$_.outputkey -eq "AvailabilityZone1"}).OutputKey
    }
}