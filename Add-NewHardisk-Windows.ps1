import-module VMware.VIMAutomation.core
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore 

#Get Vcenter Credentials
$username=""; # User name to access vCenter
$password=""  | ConvertTo-SecureString -AsPlainText  -Force; # Password to access vCenter
$creds=new-object System.Management.Automation.PSCredential -ArgumentList($username,$password)

#Get Host Credentials
$serverusername=""; # User name to access server
$serverpassword=""  | ConvertTo-SecureString -AsPlainText  -Force; # Password to access server
$servercreds=new-object System.Management.Automation.PSCredential -ArgumentList($username,$password)

#Format New disk
$Script=@"
Get-Disk  | Where-Object Isoffline -eq $true | set-disk -IsOffline $false 
$disk=get-disk | where {$_.PartitionStyle -eq 'RAW'}
Initialize-Disk -Number $disk.Number -PartitionStyle GPT | Out-Null
$drive=New-Partition -DiskNumber $disk.Number -DriveLetter $driveletter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "New Volume" -Confirm:$false
"@

$viserver="" ;# provide vCemter server details
$vm="" ; # Provide VMName
$capacityGB=""; # Enter the Disk Capacity
$outcome="Failed"
$Error.Clear()
$outcomeDescription="outcomeDescription"
$session=connect-viserver -Server $viserver -Credential $creds
try
{
$dsDetails=get-vm -name $vm | Get-Datastore | select -First 1
New-HardDisk -vm $vm -CapacityGB -Datastore $dsDetails.name -ThinProvisioned 
$outcome="success"
$outcomeDescription+=""
Invoke-VMScript -VM $vm -ScriptText $Script -HostCredential $servercreds
}
catch
{
$outcome="Failed"
$outcomeDescription+=$Error
}