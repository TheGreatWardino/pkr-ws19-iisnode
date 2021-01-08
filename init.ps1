###
# Author: Matt Ward
###

#formats the attached disk
Get-Disk | Where-Object partitionstyle -eq "raw" | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false

#sets timezone to EST
Set-TimeZone "Eastern Standard Time"

#installs Web Server (IIS) / Web Server roles
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer

#installs Web Server (IIS) / Web Server / Common HTTP Features roles
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors

#installs Web Server (IIS) / Web Server / Health and Diagnostics roles
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging

#installs Web Server (IIS) / Web Server / Security roles
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering

#installs Web Server (IIS) / Web Server / Performance roles
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic

#installs Web Server (IIS) / Management Tools roles
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole

###PRE-STAGE FOR SOFTWARE INSTALLATIONS - START ###

#force TLS for downloading software via this PowerShell session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#installs required package provider for updated IISAdministration version
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force

#forces upgrade to IISAdministration v1.1.0.0
Install-Module IISAdministration -Confirm:$false -Force

#installs Chocolatey package manager for Windows
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

###PRE-STAGE FOR SOFTWARE INSTALLATIONS - END ###

### CHOCO SOFTWARE INSTALLATIONS - START ###

#basic software needed
choco install firefox -y
choco install awscli -y
choco install jq -y
choco install notepadplusplus -y
choco install git -y
choco install nodejs-lts -y
choco install yarn -y
choco install iisnode -y
choco install urlrewrite -y

### CHOCO SOFTWARE INSTALLATIONS - END ###

###INSTALL AWSCODEDEPLOY AGENT - START###
$AWSCodeDeployMSI = "C:\Temp\codedeploy-agent.msi"
$AWSCodeDeployLog = "C:\Temp\codedeploy-agent-install.log"

#grab the latest codedeploy agent from us-east-1 and stores in temporary directory
Read-S3Object -BucketName "aws-codedeploy-us-east-1" -Key "latest/codedeploy-agent.msi" -File $AWSCodeDeployMSI

Write-Host "Installing AWS CodeDeploy..."

Start-Process -Wait msiexec -ArgumentList "/qn /i $AWSCodeDeployMSI /l $AWSCodeDeployLog"

Get-Service -Name codedeployagent
###INSTALL AWSCODEDEPLOY AGENT - END###
