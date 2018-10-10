# Windows client node configuration
## Setup and configure Windows PowerShell 5.1 and .Net 4.0
```
$link = "https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Upgrade-PowerShell.ps1"
$script = "$env:temp\Upgrade-PowerShell.ps1"
$username = "Admin"
$password = "secure_password"

(New-Object -TypeName System.Net.WebClient).DownloadFile($link, $script)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

&$script -Version 5.1 -Username $username -Password $password -Verbose

Set-ExecutionPolicy -ExecutionPolicy Restricted -Force
$reg_winlogon_path = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $reg_winlogon_path -Name AutoAdminLogon -Value 0
Remove-ItemProperty -Path $reg_winlogon_path -Name DefaultUserName -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $reg_winlogon_path -Name DefaultPassword -ErrorAction SilentlyContinue
```
## Configure WinRM on Windows PowerShell
```
$link = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$script = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($link, $script)

powershell.exe -ExecutionPolicy ByPass -File $script

```
