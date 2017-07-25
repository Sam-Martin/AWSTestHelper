function New-AWSTestEnvironmentStack {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$True)]
        [string]$Region,
        [parameter(Mandatory=$True)]
        [string]$ID,
        $VPCCidrBlock = "10.0.0.0/16",
        $PublicSubnetCidrBlock = "10.0.0.0/24"
    )

    try{
        Get-CFNStack -StackName "PowerShellAWSTestEnvironment-$ID" -Region $Region -ErrorAction Stop | Out-Null 
    }catch{
        if($_.Exception.Message -notlike '*does not exist*'){
            throw "Stack with name 'PowerShellAWSTestEnvironment-$ID' already exists! Aborting creation"
        }
    }

    $CFNPSParams = @{
        StackName = "PowerShellAWSTestEnvironment-$ID" 
        Capability = "CAPABILITY_IAM" 
        Parameter = @(
            @{
                Key="CidrBlock"
                Value = "10.0.0.0/16"
            },
            @{
                Key = "PublicSubnetACIDR"
                value = "10.0.0.0/24"
            },
            @{
                Key = "AvailabilityZone1"
                Value = (Get-EC2AvailabilityZone -Region $Region | Get-Random).ZoneName
            }
            @{
                Key = "ID"
                Value = $ID
            }
        )
        region = $Region
        TemplateBody = $(gc "$PSScriptRoot\..\files\awstesthelper-environment.yml" | out-string)
        Tag =  @{Key="PowerShellAWSTestHelperID";Value=$ID}
    }
    
    New-CFNStack @CFNPSParams

}
