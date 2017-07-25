function Remove-AWSTestVPC{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='High')]

    param(
        [Parameter(Mandatory=$true)]
        [string]$Region,
        [Parameter(Mandatory=$true)]
        [string]$ID,
        [switch]$TerminateInstances
    )
    $VPC = Get-EC2Vpc -Filter @{Name="tag:PowerShellAWSTestHelperID";Value=$ID} -Region $Region
    if(!$VPC){
        throw "No VPC found with the ID $ID"
    }

    $IGW = Get-EC2InternetGateway -Filter @{Name="tag:PowerShellAWSTestHelperID";Value=$ID} -Region $Region
    
    if ($pscmdlet.ShouldProcess($IGW.InternetGatewayId, "Deleting")){
        Write-Verbose "Removing IGW ($($IGW.InternetGatewayId))"
        Dismount-EC2InternetGateway -InternetGatewayId $IGW.InternetGatewayId -VpcId $VPC.VpcId -Region $Region -Force
        Remove-EC2InternetGateway -InternetGatewayId $IGW.InternetGatewayId -Region $Region -Force
    }

    if($TerminateInstances){
        $EC2Instances = Get-EC2Instance -Filter @{Name="vpc-id";Value=$VPC.VpcId} -Region $Region | select -ExpandProperty instances
        foreach($EC2Instance in $EC2Instances){            
            if ($pscmdlet.ShouldProcess($EC2Instance.InstanceId, "Deleting")){
                Remove-EC2Instance -InstanceId $EC2Instance.InstanceId -Region $Region -Force | Out-Null
            }
        }

        do{
            $EC2InstancesState = (Get-EC2Instance -Filter @{Name="vpc-id";Value=$VPC.VpcId} -Region $Region).Instances.State.name.value
            Write-Verbose "Waiting for instances to terminate"
            Start-Sleep -s 10
        }while($EC2InstancesState -and $EC2InstancesState -ne 'terminated')

    }

    $Subnets = Get-EC2Subnet -Filter @{Name="tag:PowerShellAWSTestHelperID";Value=$ID} -Region $Region
    foreach($Subnet in $Subnets){
        if ($pscmdlet.ShouldProcess($Subnet.SubnetId, "Deleting")){
            Write-Verbose "Removing Subnet ($($Subnet.SubnetId))"
            Remove-EC2Subnet -SubnetId $Subnet.SubnetId -Region $Region -Force
        }
    }

    if ($pscmdlet.ShouldProcess($VPC.VpcId, "Deleting")){
        Write-Verbose "Removing VPC ($($VPC.Vpcid))"
        Remove-EC2Vpc -VpcId $VPC.VpcId -Region $Region -Force
    }
}

