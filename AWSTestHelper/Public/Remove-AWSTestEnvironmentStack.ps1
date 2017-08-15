function Remove-AWSTestEnvironmentStack{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='High')]

    param(
        [Parameter(Mandatory=$true)]
        [string]$Region,
        [Parameter(Mandatory=$true)]
        [string]$ID,
        [switch]$TerminateInstances
    )
    $StackOutputs = Get-AWSTestEnvironmentStackOutputs -ID $ID -Region $Region

    
    
    if($TerminateInstances){
        $VPCFilter = @{Name="vpc-id";Value=$StackOutputs.VPCID}
        $EC2Instances = Get-EC2Instance -Filter $VPCFilter -Region $Region | select -ExpandProperty instances
        foreach($EC2Instance in $EC2Instances){            
            if ($pscmdlet.ShouldProcess($EC2Instance.InstanceId, "Deleting")){
                Remove-EC2Instance -InstanceId $EC2Instance.InstanceId -Region $Region -Force | Out-Null
            }
        }

        while($EC2Instances -and ($EC2Instances | select -Unique) -ne 'terminated'){
            $EC2Instances = (Get-EC2Instance -Filter @{Name="vpc-id";Value=$StackOutputs.VPCID} -Region $Region).Instances.State.name.value
            Write-Verbose "Waiting for instances to terminate"
            Start-Sleep -s 10
        }

    }

    if ($pscmdlet.ShouldProcess($VPC.VpcId, "Deleting")){
        Write-Verbose "Removing CFN stack PowerShellAWSTestEnvironment-$ID"
        Remove-CFNStack -StackName "PowerShellAWSTestEnvironment-$ID" -Region $Region | Out-Null
    }
}

