# How-to Guide

[README](README.md) · [Company Specification](company-spec.md) · [Problems and Resolutions](ProblemSolving.md) · [Session Record](progress-2026-10-30.md)

This is a staged runbook for the October 30 implementation, not a script to rerun from the beginning on the working environment.

**Current checkpoint:** 70 employees synchronized with Connect Sync; four shares have verified configuration. Start next session at section 8: client preparation.

Use elevated Windows PowerShell on the indicated Windows machine and sudo on Ubuntu. Store passwords securely.

## 1. VMware networks

| VMnet | Type | Subnet | Host adapter | VMware DHCP |
|---|---|---|---|---|
| VMnet8 | NAT | 10.0.0.0 / 255.255.255.0 | Off | Off |
| VMnet3 | Private/custom | 192.168.1.0 / 255.255.255.240 | Off | Off |

In Virtual Network Editor → VMnet8 → NAT Settings, verify gateway 10.0.0.2.

Attach the Ubuntu router's first NIC to VMnet8 and its second NIC to VMnet3. Attach the DC to VMnet3. Keep the host physical LAN unchanged. Existing VMnet1 and VMnet2 are outside this implementation.

The host LAN overlaps the internal subnet. Do not bridge the DC onto the physical LAN or add a host adapter to VMnet3.

## 2. Ubuntu router

| Interface | Network | Address | Default gateway |
|---|---|---|---|
| ens33 | VMnet8 upstream | 10.0.0.10/24 | 10.0.0.2 |
| ens34 | VMnet3 internal | 192.168.1.1/28 | None |

Upstream DNS: 1.1.1.1 and 8.8.8.8. Configure one default route through ens33. Check interface names before reusing these commands.

```bash
ip -br -4 addr
ip -4 route
ping -c 3 10.0.0.2
curl -I --connect-timeout 10 --max-time 20 https://ubuntu.com

printf 'net.ipv4.ip_forward=1\n' | sudo tee /etc/sysctl.d/99-lab-router.conf
sudo sysctl -p /etc/sysctl.d/99-lab-router.conf
sudo iptables -t nat -C POSTROUTING -s 192.168.1.0/28 -o ens33 -j MASQUERADE || sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/28 -o ens33 -j MASQUERADE

sudo ufw status
sudo iptables -S FORWARD
sudo iptables -t nat -S POSTROUTING
```

Observed: UFW inactive and FORWARD policy ACCEPT. The NAT command does not replace a restrictive forwarding policy on another router.

### Persistence — reboot verification pending

Save instructions were provided; successful save/reboot output was not supplied. Inspect the current rules before saving on this dedicated lab router:

```bash
sudo apt-get update
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
sudo systemctl enable netfilter-persistent
sysctl net.ipv4.ip_forward
sudo iptables -t nat -S POSTROUTING
```

After the next normal restart, recheck forwarding/rules and DC outbound connectivity. A working runtime connection does not prove persistence.

## 3. DC static addressing and DNS

On WIN-9TRC5DR3JHV:

| Field | Value |
|---|---|
| NIC network | VMnet3 |
| IPv4 | 192.168.1.2 |
| Mask | 255.255.255.240 |
| Gateway | 192.168.1.1 |
| Preferred NIC DNS | 192.168.1.2 |
| Alternate NIC DNS | Blank |

In DNS Manager, configure forwarders 1.1.1.1 and 8.8.8.8. Public resolvers are forwarders, not alternate NIC DNS for this DC or AD client.

```powershell
Get-NetIPConfiguration
Get-ADDomain | Select-Object DNSRoot, DistinguishedName
Get-DnsServerForwarder

Clear-DnsClientCache
ipconfig /registerdns
Restart-Service Netlogon
nltest /dsregdns

Resolve-DnsName "WIN-9TRC5DR3JHV.jh.test" -Server 192.168.1.2
Resolve-DnsName "_ldap._tcp.dc._msdcs.jh.test" -Type SRV -Server 192.168.1.2
dcdiag /test:Advertising /test:Services /test:DNS
ping 192.168.1.1
Test-NetConnection 1.1.1.1 -Port 443
```

The owner reported DNS passed and supplied successful gateway/TCP 443 output. Capture the broader DC health results at the next checkpoint.

## 4. Employee accounts and UPNs

The [CSV](resources/AD/employees.csv) contains 70 synthetic employees: HR 8, Engineering 35, Sales-Marketing 22, IT 5.

The [creation script](resources/AD/new-user-script-from-csv.ps1) creates department and Users child OUs and maps PositionName to Title. Accounts use lowercase firstnamelastname. The working directory is already populated; do not rebuild it.

### Review before script reuse

Inside the existing OU loop, extract the hashtable property into a scalar before filtering:

```powershell
$ouDN = [string]$ou.DN
$existingOU = Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouDN } -ErrorAction Stop
```

This documentation update preserves the existing scripts. Review/apply that correction before using the creation script in another deployment.

For a fresh deployment, configure the tenant UPN suffix first:

```powershell
$tenantSuffix = "junuihonglab.onmicrosoft.com"
$forest = Get-ADForest
if ($tenantSuffix -notin $forest.UPNSuffixes) {
    Set-ADForest -Identity $forest.Name -UPNSuffixes @{ Add = $tenantSuffix }
}

# Fresh deployment only; do not rebuild existing employees.
.\resources\AD\new-user-script-from-csv.ps1 -csvPath ".\resources\AD\employees.csv" -upnSuffix $tenantSuffix
```

The script defaults to the AD DNS suffix if no suffix is supplied. It skips existing users; it does not update their UPNs. Existing employee UPNs were updated separately during this session.

### Verify the current workforce

Run from the repository root on an AD management machine:

```powershell
$csv = @(Import-Csv ".\resources\AD\employees.csv")
$workforce = @(
    foreach ($row in $csv) {
        $sam = "$($row.FirstName.Trim())$($row.LastName.Trim())".ToLowerInvariant()
        Get-ADUser -Identity $sam -Properties Department, Title, UserPrincipalName, pwdLastSet -ErrorAction Stop
    }
)
$workforce | Group-Object Department | Select-Object Name, Count
$workforce | Select-Object SamAccountName, UserPrincipalName, Department, Title
$workforce.Count
$workforce | Group-Object SamAccountName | Where-Object Count -gt 1
```

Require 70 distinct accounts and expected department totals. The original [health-check script](resources/AD/health-check.ps1) counts only department Users OUs; it excludes Emma after her pilot move.

Emma's current DN is CN=Emma Wilson,OU=Entra-Pilot,DC=jh,DC=test. Her Department remains HR. Keep that pilot OU in scope.

## 5. Connect Sync

Cloud Sync timeout is unresolved. Its configuration is disabled and its agent stopped. Do not re-enable that engine against the same user population.

Refer to [Microsoft's custom installation guide](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-custom) for prerequisites and setup-account requirements. These selections record this lab:

1. Customize; retain required-component defaults.
2. Select Password Hash Synchronization; Seamless SSO was not enabled.
3. Connect the correct Entra tenant with an authorized setup administrator.
4. Add jh.test and allow creation of a connector account. Do not reuse the Cloud Sync gMSA.
5. Retain userPrincipalName for sign-in; employee UPNs use the tenant suffix. jh.test is not a verified public sign-in domain.
6. Initially select only Entra-Pilot in Domain/OU Filtering.
7. Retain ordinary identity/source-anchor defaults; do not invent immutable IDs.
8. Keep all users within the selected OU scope; no extra group filter.
9. Enable only the needed optional features, including PHS.
10. Leave automatic initial sync unchecked during review. Staging mode was not enabled.
11. Complete configuration.

Load commands using the installed path; the short module name failed on this server:

```powershell
Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1" -ErrorAction Stop
Get-Service ADSync
Get-ADSyncScheduler | Select-Object SyncCycleEnabled, StagingModeEnabled, SyncCycleInProgress

# Pilot setup only.
Set-ADSyncScheduler -SyncCycleEnabled $false
Start-ADSyncSyncCycle -PolicyType Initial
```

A returned Success accepts a request; it does not prove every export completed. Review Synchronization Service Manager → Operations and the Entra user properties.

### Pilot authentication and attribute test

Verify Emma has on-premises sync enabled, expected UPN/SamAccountName, jh.test source domain, pilot DN, and Department HR.

Emma had pwdLastSet = 0. This pilot cleared the temporary-password requirement and reset her password:

```powershell
Get-ADUser emmawilson -Properties Enabled, LockedOut, pwdLastSet | Select-Object Enabled, LockedOut, pwdLastSet

# Pilot only: enter a new password securely.
Set-ADUser emmawilson -ChangePasswordAtLogon $false
$pilotPassword = Read-Host "Enter a new pilot password" -AsSecureString
Set-ADAccountPassword emmawilson -Reset -NewPassword $pilotPassword
Remove-Variable pilotPassword
```

Allow PHS to process, then test cloud sign-in in a private browser. Emma's sign-in passed. This was not a password reset for the other 69 employees. Object/attribute scheduling and PHS are separate, as described in the [scheduler documentation](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-feature-scheduler).

The attribute test also passed:

```powershell
Set-ADUser emmawilson -Title "HR Coordinator"
Start-ADSyncSyncCycle -PolicyType Delta
```

### Workforce expansion

The owner removed old cloud-only test employees first. Do not repeat those deletions.

Through the Connect wizard, select HR, Engineering, Sales-Marketing, IT, their employee child OUs, and Entra-Pilot. Exclude unrelated default Computers, Users, Domain Controllers, Builtin, and service/system containers. Do not select the whole domain as a shortcut.

Run Initial after reviewing scope, inspect exports, and verify employee counts. Observed directory population: 70 employees + retained administrator + Sales object = 72.

After successful verification:

```powershell
Set-ADSyncScheduler -SyncCycleEnabled $true
Get-ADSyncScheduler | Select-Object SyncCycleEnabled, StagingModeEnabled, SyncCycleInProgress
```

The owner reported scheduler enabling; capture its output again next session. Moving users out of scope can delete their cloud objects.

## 6. Department security groups

AGDLP: Account → Global Security Group → Domain Local Security Group → Permission.

| Department | Global group | Employees | Modify group | Read group |
|---|---|---:|---|---|
| HR | GG_HR_Users | 8 | DL_HR_Share_Modify | DL_HR_Share_Read |
| Engineering | GG_ENG_Users | 35 | DL_ENG_Share_Modify | DL_ENG_Share_Read |
| Sales-Marketing | GG_SM_Users | 22 | DL_SM_Share_Modify | DL_SM_Share_Read |
| IT | GG_IT_Users | 5 | DL_IT_Share_Modify | DL_IT_Share_Read |

Place groups under the respective department OU. Add employees by Department, including Emma outside the HR OU. Nest each GG in its Modify DL. Keep Read DL groups empty until required.

The owner progressed through setup; final direct membership output is not archived. Verify before client tests:

```powershell
foreach ($code in "HR", "ENG", "SM", "IT") {
    $gg = "GG_${code}_Users"
    $modify = "DL_${code}_Share_Modify"
    $read = "DL_${code}_Share_Read"

    Get-ADGroup $gg -Properties GroupScope, GroupCategory | Select-Object Name, GroupScope, GroupCategory
    [pscustomobject]@{
        Department = $code
        Employees = @(Get-ADGroupMember $gg -Recursive | Where-Object ObjectClass -eq "user").Count
    }
    Get-ADGroupMember $modify | Select-Object Name, ObjectClass
    Get-ADGroupMember $read | Select-Object Name, ObjectClass
}
```

Require matching GG nesting and employee counts. Department membership must not grant administrator privileges.

## 7. File shares

| Share | Folder |
|---|---|
| HR$ | C:\LabShares\HR |
| ENG$ | C:\LabShares\ENG |
| SM$ | C:\LabShares\SM |
| IT$ | C:\LabShares\IT |

All four have:
- Administrators: SMB Full and NTFS Full.
- SYSTEM: NTFS Full.
- Department Modify DL: SMB Change and NTFS Modify.
- Department Read DL: SMB Read and NTFS Read & Execute.
- Explicit inheritable NTFS entries, with inherited broad grants removed.
- Access-Based Enumeration enabled and no cross-department Deny entries.

Verify:

```powershell
foreach ($code in "HR", "ENG", "SM", "IT") {
    $share = "$code$"
    $path = "C:\LabShares\$code"
    Get-SmbShare -Name $share | Select-Object Name, Path, FolderEnumerationMode
    Get-SmbShareAccess -Name $share
    icacls $path
}
```

Supplied output matches the intended settings. A trailing dollar sign hides browsing; ACLs enforce access. Access-Based Enumeration does not replace permissions.

### Reproduction on new, empty lab folders only

The existing shares already exist; do not rerun this creation block there. It stops if any target folder or share exists.

```powershell
$codes = "HR", "ENG", "SM", "IT"
$domain = (Get-ADDomain).NetBIOSName
$adminSid = [System.Security.Principal.SecurityIdentifier]"S-1-5-32-544"
$admins = $adminSid.Translate([System.Security.Principal.NTAccount]).Value

foreach ($code in $codes) {
    if ((Test-Path "C:\LabShares\$code") -or (Get-SmbShare -Name "$code$" -ErrorAction SilentlyContinue)) {
        throw "Existing folder or share requires manual review: $code"
    }
    Get-ADGroup "DL_${code}_Share_Modify" -ErrorAction Stop | Out-Null
    Get-ADGroup "DL_${code}_Share_Read" -ErrorAction Stop | Out-Null
}

foreach ($code in $codes) {
    $path = "C:\LabShares\$code"
    $modify = "$domain\DL_${code}_Share_Modify"
    $read = "$domain\DL_${code}_Share_Read"
    New-Item -ItemType Directory -Path $path -ErrorAction Stop | Out-Null

    icacls $path /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)(F)" "*S-1-5-32-544:(OI)(CI)(F)" "${modify}:(OI)(CI)(M)" "${read}:(OI)(CI)(RX)"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply folder permissions: $path"
    }
    New-SmbShare -Name "$code$" -Path $path -FullAccess $admins -ChangeAccess $modify -ReadAccess $read -FolderEnumerationMode AccessBased -CachingMode None -ErrorAction Stop
}
```

Do not apply this as a general permissions reset to an existing data tree.

## 8. Client preparation — next session

**Pending.** Preserve Win11-Intune: Entra joined, not AD-domain joined, with administrator credentials unavailable.

The replacement win-lab needs correct installation media and a clean installation.

1. Verify Windows 11 Pro/Enterprise media and installed edition.
2. Establish a known local administrator through supported setup and store its password securely.
3. Confirm that account can approve elevation before identity changes.
4. Inspect device join state before organizational sign-in.
5. Connect the NIC to VMnet3.

An Emma sign-in during OOBE does not create a local AD-domain client.

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
dism /online /Get-CurrentEdition
Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain
dsregcmd /status
$adminGroup = Get-LocalGroup -SID "S-1-5-32-544"
Get-LocalGroupMember -Group $adminGroup.Name
```

Assign an unused test address, proposed as 192.168.1.10/28, gateway 192.168.1.1, DNS 192.168.1.2. This tests server-segment functionality; it does not reproduce the HR Data VLAN.

Before joining:

```powershell
Resolve-DnsName "_ldap._tcp.dc._msdcs.jh.test" -Type SRV -Server 192.168.1.2
Test-NetConnection "WIN-9TRC5DR3JHV.jh.test" -Port 445

# Supply an authorized AD join account.
Add-Computer -DomainName "jh.test" -Credential (Get-Credential) -Restart
```

After restart, sign in as JH\emmawilson:

```powershell
whoami
whoami /groups
Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain
```

Domain join does not automatically implement hybrid Entra join or Intune enrollment.

## 9. Functional share tests — pending

Use a standard Emma session on the prepared client. Reauthenticate after group changes.

| Test | Expected |
|---|---|
| Emma → HR$ | Create/read/edit/delete allowed |
| Emma → ENG$, SM$, IT$ | Access denied |
| Designated Read DL test user, if assigned | Read allowed; write/delete denied |
| Administrator → shares | Administrative access, not employee acceptance |

Positive test:

```powershell
$share = '\\WIN-9TRC5DR3JHV.jh.test\HR$'
$testFile = Join-Path $share ("emma-access-test-{0}.txt" -f [guid]::NewGuid())
Set-Content -LiteralPath $testFile -Value "HR create test" -ErrorAction Stop
Get-Content -LiteralPath $testFile -ErrorAction Stop
Add-Content -LiteralPath $testFile -Value "HR edit test" -ErrorAction Stop
Get-Content -LiteralPath $testFile -ErrorAction Stop
Remove-Item -LiteralPath $testFile -ErrorAction Stop
```

Open the other shares in Explorer and capture access denied. A missing network path is not evidence of authorization denial. Record user, source client, target, expected/actual result, and evidence.

If SMB credentials conflict, inspect connections and remove only the specific test connection. Do not clear all mapped connections.

No employee positive/negative share-access results have been captured yet.

## 10. Shutdown, startup, and continuation

Shutdown: Windows client → AD server → Ubuntu router. Use normal Windows shutdown and, on Ubuntu:

```bash
sudo shutdown -h now
```

Wait for guests to power off before closing VMware. Start in dependency order: router → AD server → client.

After startup, verify router persistence, DC DNS/outbound access, and the ADSync scheduler. Continue file tests, GPO/logon restrictions, departmental DHCP/routing, and selected M365/Intune tests.

For unresolved issues, see [Problems and Resolutions](ProblemSolving.md). Pending steps are not recorded as passed.
