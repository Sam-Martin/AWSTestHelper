# AWSTestHelper [![Build status](https://ci.appveyor.com/api/projects/status/0u01ondgmpo9hel7?svg=true)](https://ci.appveyor.com/project/Sam-Martin/awstesthelper)

Set of PowerShell cmdlets for safely spinning AWS VPCs up and down for testing purposes. 
This module is useful when you want to quickly spin up an isolated, short-lived instance for testing purposes.

# Usage
Installation can be done from the [PowerShell Gallery](https://www.powershellgallery.com/packages/AWSTestHelper/) using the following command.

```
Install-Module -Name AWSTestHelper
```

## VPC Creation
This module handles the creation of an AWS VPC including:
* Internet Gateway
* 1 x Public Subnet
* EC2 Role with SSM rights

This is achieved using the `New-AWSTestEnvironmentStack` cmdlet.

### Example 
```
New-AWSTestEnvironmentStack -Region eu-west-1 -ID Default
```

## Waiting for VPC Creation
The creation of a new VPC and resources listed above can take some time. In order to let your script wait for the VPC creation, you can use the `Wait-AWSTestEnvironmentStackCreation` cmdlet.

### Example 
```
Wait-AWSTestEnvironmentStackCreation -Region eu-west-1 -ID Default
``` 

## VPC Discovery
Once the VPC has been created you can find the pertinent resource IDs using the `Get-AWSTestEnvironmentStackOutputs` cmdlet.

### Example 
```
Get-AWSTestEnvironmentStackOutputs -Region eu-west-1 -ID Default
```

## VPC Deletion
Once you have finished with your test VPC, you can delete it using the `Remove-AWSTestEnvironmentStack` cmdlet.
### Example 
```
Remove-AWSTestEnvironmentStack -Region eu-west-1 -ID Default -TerminateInstances -Confirm:$false
```
*Note:* using the `-TerminateInstances` switch will force the termination of instances launched in the VPC.

## Identity
You will note in the examples above that a parameter `-ID` is used in every cmdlet. This identifier is appended to the name of all resources to ensure that they are uniquely identifiable.  
**Important:** The value you pass to `-ID` is case sensitive.

# Authors
 - Sam Martin (samjackmartin@gmail.com)