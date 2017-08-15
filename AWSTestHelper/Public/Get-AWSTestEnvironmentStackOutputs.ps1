Function Get-AWSTestEnvironmentStackOutputs{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$True)]
        [string]$ID,
        [parameter(Mandatory=$True)]
        [string]$Region
    )
    $CFNStack = Get-CFNStack -StackName "PowerShellAWSTestEnvironment-$ID" -Region $Region -ErrorAction SilentlyContinue
    if($CFNStack.StackStatus -ne "CREATE_COMPLETE" -and $CFNStack.StackStatus -ne "UPDATE_COMPLETE"){
        throw "CFN Stack updating or deleting, not returning resource info"
    }
    if(!$CFNStack){
        throw "No CFN stack found with the name PowerShellAWSTestEnvironment-$ID"
    }

    return @{
        VPCID = ($CFNStack.Outputs | ?{$_.outputkey -eq "VPCID"}).OutputValue
        PublicSubnetID = ($CFNStack.Outputs | ?{$_.outputkey -eq "PublicSubnetAID"}).OutputValue
        AvailabilityZone = ($CFNStack.Outputs | ?{$_.outputkey -eq "AvailabilityZone1"}).OutputValue
        SSMInstanceProfileID = ($CFNStack.Outputs | ?{$_.outputkey -eq "SSMInstanceProfileID"}).OutputValue
    }
}