---
title: "Accessing Windows EC2 Instances via SSH"
date: 2023-01-21T12:12:11-06:00
draft: false
---

# Accessing Windows EC2 Instances via SSH

{{< hint info >}}
**Too Long; Didn't Read**

This post started life as a Stackoverflow answer I posted [here](https://stackoverflow.com/a/75009915/8468492).
See that post for the same outcome with slightly less detail.
{{< /hint >}}

Remote Windows instances have typically been accessed via either the [Remote Desktop Protocol (RDP)](https://learn.microsoft.com/en-us/troubleshoot/windows-server/remote/understanding-remote-desktop-protocol) for interactive use or [Windows Remote Management (WinRM)](https://learn.microsoft.com/en-us/windows/win32/winrm/portal) for programmatic access.
Recent releases of Windows, though, offer official support for Secure Shell (SSH) via the OpenSSH daemon.
This post walks through the setup of a Windows EC2 instance in AWS so it can be accessed via SSH.

## Supported Versions of Windows

As of this writing, the supported versions of Windows described in the Microsoft Learn article ["Get started with OpenSSH for Windows"](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell) are

- Windows 10 build 1809 and later
- Windows Server 2019
- Windows Server 2022

The steps in this guide have been tested against Server 2019.
Specifically, I used the base Amazon Machine Image (AMI) `Windows_Server-2019-English-Full-ECS_Optimized-2022.12.14`.

## Building an AMI

To be able to connect to a Windows EC2 instance via SSH once the image has started, the OpenSSH `sshd` and `ssh-agent` services need to be installed and set to run on boot.
The above ["Get started with OpenSSH for Windows"](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell) article includes the relevant commands to accomplish this.
Here they are as a single PowerShell script:

```powershell
$ErrorActionPreference = 'Stop'

Write-Host 'Installing and starting sshd'
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

Write-Host 'Installing and starting ssh-agent'
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent

Write-Host 'Set PowerShell as the default SSH shell'
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value (Get-Command powershell.exe).Path -PropertyType String -Force
```

## Launching the Instance

Once an AMI with the above setup has been successfully built, there are a handful of options to pay attention to when launching the actual EC2 instance.

1. You _must_ provide a valid SSH keypair.
2. You _must_ ensure the public half of that keypair is added to your preferred user's list of authenticated keys on startup.
3. You should use IMDSv2.

Of these, dynamically adding the public key is the only step that doesn't have a dedicated option in AWS.
The following PowerShell script serves the purpose of configuration the `Administrator` user's authorized keys file.
It should be provided as the instance's userdata script.
Note that the `<powershell>` and `</powershell>` tags _are_ intentional parts of the userdata;
they are parsed and extracted by AWS prior to the script being executed.

```powershell
<powershell>

# Userdata script to enable SSH access as user Administrator via SSH keypair.
# This assumes that
# 1. the SSH service (sshd) has already been installed, configured, and started during AMI creation;
# 2. a valid SSH key is selected when the EC2 instance is being launched; and
# 3. IMDSv2 is selected when launching the EC2 instance.

# Save the private key from instance metadata.
$ImdsToken = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/api/token' -Method 'PUT' -Headers @{'X-aws-ec2-metadata-token-ttl-seconds' = 2160} -UseBasicParsing).Content
$ImdsHeaders = @{'X-aws-ec2-metadata-token' = $ImdsToken}
$AuthorizedKey = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key' -Headers $ImdsHeaders -UseBasicParsing).Content
$AuthorizedKeysPath = 'C:\ProgramData\ssh\administrators_authorized_keys'
New-Item -Path $AuthorizedKeysPath -ItemType File -Value $AuthorizedKey -Force

# Set appropriate permissions on administrators_authorized_keys by copying them from an existing key.
Get-ACL C:\ProgramData\ssh\ssh_host_dsa_key | Set-ACL $AuthorizedKeysPath

# Ensure the SSH agent pulls in the new key.
Set-Service -Name ssh-agent -StartupType "Automatic"
Restart-Service -Name ssh-agent

</powershell>
```

## Connecting to the Instance

The resulting instance can be connected to via SSH like normal.
Simply specify the relevant SSH private key and user.
For example:

```shell
ssh -i ~/.ssh/my-keypair Administrator@my.ec2.instance
```
