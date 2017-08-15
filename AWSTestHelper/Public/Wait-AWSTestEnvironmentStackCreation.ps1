function Wait-AWSTestEnvironmentStackCreation {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$True)]
        [string]$ID,
        [parameter(Mandatory=$True)]
        [string]$Region
    )

    if(!(Get-CFNStack -StackName "PowerShellAWSTestEnvironment-$ID" -Region $Region -ErrorAction SilentlyContinue)){
        throw "No CFN stack found with the name PowerShellAWSTestEnvironment-$ID"
    }

    while((Get-CFNStack -StackName "PowerShellAWSTestEnvironment-$ID" -Region $Region).StackStatus -eq "CREATE_IN_PROGRESS"){
        Write-Verbose "Waiting for stack creation..."
        Start-Sleep -s 10
    }
    Get-CFNStack -StackName "PowerShellAWSTestEnvironment-Default" -Region $Region
}