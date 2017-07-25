function New-AWSTestVPC {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$True)]
        [string]$Region,
        [parameter(Mandatory=$True)]
        [string]$ID,
        $VPCCidrBlock = "10.0.0.0/16",
        $PublicSubnetCidrBlock = "10.0.0.0/24"
    )

    if(Get-EC2VPC -Filter @{Name="tag:Name";Value="PowerShellAWSTestVPC-$ID"} -Region $Region){
        throw "VPC with name 'PowerShellAWSTestVPC-$ID' already exists! Aborting creation"
    }

    $VPC = New-EC2Vpc -CidrBlock $VPCCidrBlock -Region $Region
   
    do{
        $VPCCheck = Get-EC2Vpc -VpcId $Vpc.VpcId -Region $Region
        Write-Verbose "Waiting for VPC to become available"
        Start-Sleep -s 5
    }while($VPCCheck.State -eq "Pending")
    
    Write-Verbose "Tagging VPC"
    New-EC2Tag -Resource $VPC.VpcId -Tag @{Key="Name";Value="PowerShellAWSTestVPC-$ID"} -Region $Region
    New-EC2Tag -Resource $VPC.VpcId -Tag @{Key="PowerShellAWSTestHelperID";Value=$ID} -Region $Region

    Write-Verbose "Creating and attaching IGW to $($VPC.VpcId)"
    $IGW = New-EC2InternetGateway -Region $Region
    Add-EC2InternetGateway -InternetGatewayId $IGW.InternetGatewayId -VpcId $VPC.VpcId -Region $Region 
    New-EC2Tag -Resource $IGW.InternetGatewayId -Tag @{Key="PowerShellAWSTestHelperID";Value=$ID} -Region $Region

    Write-Verbose "Creating Public Subnet"
    $params = @{
        VpcId = $VPC.VpcId; 
        CidrBlock = $PublicSubnetCidrBlock; 
        AvailabilityZone = Get-EC2AvailabilityZone -Region $Region | Get-Random | Select-Object -ExpandProperty ZoneName
        Region = $Region
    }
    $PublicSubnet = New-EC2Subnet @params 
    Edit-EC2SubnetAttribute -MapPublicIpOnLaunch $true -SubnetId $PublicSubnet.SubnetId -Region $Region -Force
    New-EC2Tag -Resource $PublicSubnet.SubnetID -Tag @{Key="Name";Value="PowerShellAWSTestPublicSubnet-$ID"} -Region $Region
    New-EC2Tag -Resource $PublicSubnet.SubnetID -Tag @{Key="PowerShellAWSTestHelperID";Value=$ID} -Region $Region


    return @{
        "VPC" = $VPCCheck
        "PublicSubnet" = $PublicSubnet
    }

}
