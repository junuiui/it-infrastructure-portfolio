# How-to Guide

[README](README.md) · [Company Specification](company-spec.md) · [Problems and Resolutions](ProblemSolving.md) · [October 31 Record](progress-2026-10-31.md)

This staged runbook covers the October 30–31 integration. Windows administrative changes use the GUI where practical; Ubuntu and focused verification use terminal commands. Do not rerun historical provisioning/recovery steps against the completed environment.

**Current checkpoint:** Four department data networks, workstation/file authorization, joiner/mover/leaver scenarios, Jamie's M365 access, hybrid join, Intune enrollment, HR compliance and login-banner delivery have passed the recorded tests. HR-PC-01 is back on HR/VMnet4. Remaining closeout is in section 16.

Use elevated Windows PowerShell on the indicated Windows machine and sudo on Ubuntu. Store passwords securely.

## 1. VMware networks

| VMnet | Type | Subnet | Host adapter | VMware DHCP |
|---|---|---|---|---|
| VMnet8 | NAT | 10.0.0.0 / 255.255.255.0 | Off | Off |
| VMnet3 | Private/custom | 192.168.1.0 / 255.255.255.240 | Off | Off |
| VMnet4 | Host-only | 192.168.0.192 / 255.255.255.224 | Off | Off |
| VMnet5 | Host-only | 192.168.0.0 / 255.255.255.192 | Off | Off |
| VMnet6 | Host-only | 192.168.1.64 / 255.255.255.192 | Off | Off |
| VMnet7 | Host-only | 192.168.1.16 / 255.255.255.240 | Off | Off |

In Virtual Network Editor → VMnet8 → NAT Settings, verify gateway 10.0.0.2.

Attach the Ubuntu router's first NIC to VMnet8 and its second NIC to VMnet3. Attach the DC to VMnet3. Keep the host physical LAN unchanged. Existing VMnet1 and VMnet2 are outside this implementation.

The host LAN overlaps the internal subnet. Do not bridge the DC onto the physical LAN or add a host adapter to VMnet3.

## 2. Ubuntu router

| Interface | Network | Address | Default gateway |
|---|---|---|---|
| ens33 | VMnet8 upstream | 10.0.0.10/24 | 10.0.0.2 |
| ens34 | VMnet3 server | 192.168.1.1/28 | None |
| ens38 | VMnet4 HR | 192.168.0.193/27 | None |
| ens39 | VMnet5 ENG | 192.168.0.1/26 | None |
| ens40 | VMnet6 SM | 192.168.1.65/26 | None |
| ens41 | VMnet7 IT | 192.168.1.17/28 | None |

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

### Persistence — expanded-stack reboot verification passed

The expanded router was shut down and restarted. Evidence confirms all six interfaces, the single default route, forwarding, five NAT entries and Relay startup persisted. The commands used to save/inspect the dedicated router remain:

```bash
sudo apt-get update
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
sudo systemctl enable netfilter-persistent
sysctl net.ipv4.ip_forward
sudo iptables -t nat -S POSTROUTING
```

Repeat the checks after future changes. The completed restart validation is recorded in section 16; runtime-only checks are not a substitute for it.

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

This CSV-scoped check should still find the original 70 distinct accounts, including disabled Emma. It is not the complete live inventory after adding Jamie in section 11. Section 17 contains the current 71/70/1 Saved Query validation. The original [health-check script](resources/AD/health-check.ps1) counts department Users OUs without enabled-state filtering. It excluded Emma while she was in Entra-Pilot; current evidence places her in HR/Users. Use the Saved Queries in section 17 for the validated live counts.

Emma was initially in Entra-Pilot. New evidence shows her in HR/Users; she remains disabled for the leaver test. Retained users remain within sync scope. Use Ava/Jamie for current HR access tests.

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

### Historical pilot authentication and attribute test

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

The October 31 startup screenshot confirmed the scheduler enabled, staging mode off, and ADSync Running. Capture the state again at final restart. Moving users out of scope can delete their cloud objects.

## 6. Department security groups

AGDLP: Account → Global Security Group → Domain Local Security Group → Permission.

| Department | Global group | Employees | Modify group | Read group |
|---|---|---:|---|---|
| HR | GG_HR_Users | 8 | DL_HR_Share_Modify | DL_HR_Share_Read |
| Engineering | GG_ENG_Users | 35 | DL_ENG_Share_Modify | DL_ENG_Share_Read |
| Sales-Marketing | GG_SM_Users | 22 | DL_SM_Share_Modify | DL_SM_Share_Read |
| IT | GG_IT_Users | 5 | DL_IT_Share_Modify | DL_IT_Share_Read |

Place groups under the respective department OU. Add employees by Department, including Emma outside the HR OU. Nest each department GG in its Modify DL. HR Read was subsequently tested using the temporary GG-HR-ReadOnly_Test group, then cleaned up; see section 18.

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

Require appropriate GG-to-DL nesting. Baseline counts are historical: Jamie was added to HR and Emma retained disabled. Membership count need not equal enabled-user count. Department membership must not grant administrator privileges.

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

## 8. Windows client installation and GUI domain join

The deployed client is Windows 11 Pro, computer HR-PC-01. The earlier Entra-only Intune VM remains separate.

For a fresh client:
1. Connect correct Windows Pro/Enterprise media and verify the edition; Home cannot join this AD domain.
2. During the observed setup flow, select Set up for work or school → Sign-in options → Domain join instead.
3. Create LabAdmin and securely record its password. This local account is separate from VMware TPM encryption and AD account credentials.
4. Confirm local administrator elevation before organizational changes.
5. Initially attach the NIC to VMnet3 and use an unused temporary address such as 192.168.1.10/28, gateway 192.168.1.1, DNS 192.168.1.2.
6. Open Win+R → sysdm.cpl → Computer Name → Change.
7. Set name HR-PC-01 and domain jh.test. Supply an authorized AD join account when prompted.
8. Finish and restart. Use Other user for AD sign-in.
9. For local recovery/admin sign-in use .\LabAdmin or HR-PC-01\LabAdmin. A bare LabAdmin may be interpreted in domain JH.
10. For final operation, use the HR DHCP network in section 10, not the temporary static address.

Verification:
```powershell
dism /online /Get-CurrentEdition
whoami
Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain
dsregcmd /status
```

Ordinary user accounts remain nonadministrators. Elevation with local LabAdmin does not require changing Jamie's group membership.

## 9. Computer OUs, logon GPOs, and shares

### GUI workstation restrictions

On the DC:
1. Server Manager → Tools → Active Directory Users and Computers.
2. Create Computers child OUs under HR, Engineering, Sales-Marketing and IT.
3. Move the computer object into the intended department's Computers OU.
4. Open Group Policy Management. At each department Computers OU, create/link its workstation-logon GPO.
5. Edit Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies → User Rights Assignment → Allow log on locally.
6. Define the setting with only Administrators and the matching department Global group.

| Computer OU | GPO | Employee group |
|---|---|---|
| HR/Computers | GPO-HR-Workstation-Logon | JH\GG_HR_Users |
| Engineering/Computers | GPO-ENG-Workstation-Logon | JH\GG_ENG_Users |
| Sales-Marketing/Computers | GPO-SM-Workstation-Logon | JH\GG_SM_Users |
| IT/Computers | GPO-IT-Workstation-Logon | JH\GG_IT_Users |

Keep BUILTIN/Administrators to preserve local/domain administrative access. Do not include broad Users or Domain Users in the employee allow list. Leave Deny log on locally unchanged. Keep the default Authenticated Users GPO Security Filtering; these are computer policies. Do not link workstation restrictions at domain root or Domain Controllers.

On the client, apply and inspect:
```powershell
gpupdate /force
gpresult /r /scope computer
```

GUI confirmation: Win+R → secpol.msc → Local Policies → User Rights Assignment → Allow log on locally.

Test a standard same-department employee, then a different department employee with a known valid password. Expected negative result is sign-in method not allowed. Incorrect-password or disabled-account errors are separate tests. Log out fully to renew tokens after group changes.

This controls console logon; RDP and network resource rights are separate.

### Functional resource tests

Sign in with the intended standard employee. Explorer address:
```text
\\WIN-9TRC5DR3JHV.jh.test\HR$
```

For the matching share, create a new text file, enter content, save, reopen, edit, save and delete. Try the designated other department shares and capture explicit permission denial. Do not enter administrator credentials to make an employee test pass.

Network browsing can be empty because discovery is off, and dollar-suffixed shares are hidden. Use a direct UNC path. A 0KB pre-existing file is not evidence of successful content changes.

Validated roles: Ava Collins/HR, Luke Fisher/ENG, Nora Green/SM, Nolan Allen/IT. The HR Read tier was subsequently tested separately; see section 18.

## 10. Department networks, Windows DHCP, and Ubuntu Relay

### VMware and NIC mapping

Use Virtual Network Editor as administrator. Create VMnet4–7 from section 1 with host adapters and VMware DHCP off.

Shut down Ubuntu normally before adding NICs. Add one adapter for each department, attach it to the correct VMnet, and enable Connect at power on. Preserve WAN/server adapters.

Check VMware adapter Advanced/MAC against:
```bash
ip -br link
ip -br -4 addr
```

Verified mapping for this router:
- ens38 → HR/VMnet4, MAC ending :8e.
- ens39 → ENG/VMnet5, :98.
- ens40 → SM/VMnet6, :a2.
- ens41 → IT/VMnet7, :ac.

These names are concrete to this VM. For another VM, use its actual names.

### Netplan

Preserve existing ens33/ens34 configuration. HR is in /etc/netplan/60-hr-network.yaml:
```yaml
network:
  version: 2
  ethernets:
    ens38:
      dhcp4: false
      addresses:
        - 192.168.0.193/27
```

Additional departments are in /etc/netplan/70-department-networks.yaml:
```yaml
network:
  version: 2
  ethernets:
    ens39:
      dhcp4: false
      addresses:
        - 192.168.0.1/26
    ens40:
      dhcp4: false
      addresses:
        - 192.168.1.65/26
    ens41:
      dhcp4: false
      addresses:
        - 192.168.1.17/28
```

Do not add internal default routes or DNS settings. Save with nano Ctrl+O, Enter, Ctrl+X, then:
```bash
sudo chmod 600 /etc/netplan/60-hr-network.yaml /etc/netplan/70-department-networks.yaml
sudo netplan generate
sudo netplan try
```

Accept with Enter within the timeout only if connectivity is correct:
```bash
ip -br -4 addr
ip -4 route
```

Expect six addressed NICs and one default route via 10.0.0.2. Do not retain ENG_NIC/SM_NIC/IT_NIC placeholders; YAML validity does not verify real NIC matching.

### Windows DHCP GUI

On the DC:
1. Server Manager → Manage → Add Roles and Features → Role-based installation.
2. Select DHCP Server and required management features; install if absent.
3. Notification flag → Complete DHCP configuration → authorized AD administrator → Commit.
4. Tools → DHCP; authorize the server if needed and refresh.
5. IPv4 → New Scope, once for each department.

| Scope | Start | End | Prefix/mask | Router |
|---|---|---|---|---|
| HR-Data | 192.168.0.194 | 192.168.0.219 | /27, 255.255.255.224 | 192.168.0.193 |
| ENG-Data | 192.168.0.2 | 192.168.0.59 | /26, 255.255.255.192 | 192.168.0.1 |
| SM-Data | 192.168.1.66 | 192.168.1.125 | /26, 255.255.255.192 | 192.168.1.65 |
| IT-Data | 192.168.1.18 | 192.168.1.27 | /28, 255.255.255.240 | 192.168.1.17 |

Each wizard:
- No extra exclusions needed for these already-limited pools.
- Retain default lease duration.
- Configure options now.
- Router: enter matching address and click Add.
- Parent domain jh.test; DNS 192.168.1.2 only.
- WINS blank; activate scope.
- Confirm Scope Options 003 Router, 006 DNS Servers, 015 DNS Domain Name.

No voice/default serverPool scope is required for this Windows implementation.

### DHCP Relay and Internet NAT

On Ubuntu:
```bash
sudo apt-get update
sudo apt-get install isc-dhcp-relay
sudo nano /etc/default/isc-dhcp-relay
```

Set:
```bash
SERVERS="192.168.1.2"
INTERFACES="ens38 ens34 ens39 ens40 ens41"
OPTIONS=""
```

WAN ens33 is excluded. Save and start:
```bash
sudo systemctl restart isc-dhcp-relay
sudo systemctl enable isc-dhcp-relay
sudo systemctl status isc-dhcp-relay --no-pager
```

Require active/running. If it fails:
```bash
sudo journalctl -u isc-dhcp-relay -n 60 --no-pager
```

Preserve existing rules and add only missing outbound NAT entries:
```bash
for subnet in 192.168.1.0/28 192.168.0.192/27 192.168.0.0/26 192.168.1.64/26 192.168.1.16/28; do
    sudo iptables -t nat -C POSTROUTING -s "$subnet" -o ens33 -j MASQUERADE ||
    sudo iptables -t nat -A POSTROUTING -s "$subnet" -o ens33 -j MASQUERADE
done
sudo netfilter-persistent save
sysctl net.ipv4.ip_forward
sudo iptables -S FORWARD
sudo iptables -t nat -S POSTROUTING
```

The existing router used forwarding 1 and FORWARD ACCEPT. These commands do not replace a separate restrictive firewall policy.

### Sequential client acceptance

Do not build extra PCs merely to repeat the functional test. Use LabAdmin while moving the representative client.

For each department:
1. ADUC → move computer object to matching department/Computers OU.
2. While still on the old network, run ipconfig /release.
3. VMware → client NIC → correct Custom VMnet.
4. Windows Win+R → ncpa.cpl → Ethernet Properties → IPv4: obtain IP and DNS automatically.
5. Renew, verify connectivity, and refresh GPO:
```powershell
ipconfig /renew
ipconfig /all
Resolve-DnsName "_ldap._tcp.dc._msdcs.jh.test" -Type SRV
Test-NetConnection 192.168.1.2 -Port 445 -InformationLevel Quiet
Test-NetConnection 1.1.1.1 -Port 443 -InformationLevel Quiet
gpupdate /force
gpresult /r /scope computer
```
6. Check the lease, gateway, mask, AD DNS, and matching GPO. A 169.254 address is a DHCP failure, not a usable result.
7. DHCP console → scope → Address Leases: inspect the client.
8. Sign out; use the matching employee for file/logon tests.
9. Return through LabAdmin for the next network.
10. Finally restore HR/Computers and VMnet4, renew and apply HR GPO; test Ava login.

The name HR-PC-01 remained unchanged during temporary roles. OU placement does not change VMnet/IP; network placement does not change identity permissions.

## 11. Joiner, mover, and leaver GUI runbooks

These are the completed scenarios, not instructions to recreate existing accounts.

### Joiner — Jamie Morgan

ADUC → HR/Users → New User:
- First/last Jamie Morgan.
- SamAccountName jamiemorgan; tenant-suffix UPN.
- Secure initial password; no forced first-logon change for this PHS pilot.
- Enabled account.
- Properties → Organization: Department HR, Title HR Assistant.
- Member Of: add GG_HR_Users; retain Domain Users.

Test AD sign-in and HR resource rights, then synchronize:
```powershell
Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"
Start-ADSyncSyncCycle -PolicyType Delta
```

After export completes, verify synced/enabled Entra user and attributes. In a private browser, sign in to https://myaccount.microsoft.com using Jamie's UPN and AD password.

### Mover — temporary Engineering-to-HR change

1. Record original identity, OU, Department and direct groups.
2. Change Department in Organization.
3. Remove the old department GG and add the new GG explicitly.
4. Move the user within the already-synced department OUs.
5. Sign out fully and test new workstation/file permissions and loss of old access.
6. Restore the original state for this temporary lab test.

The owner completed/restored this scenario, but the test identity was not recorded. Do not infer automation from a manual group update.

### Leaver — Emma

1. Sign out the employee from the test workstation.
2. ADUC → user → Disable Account. Retain the object in sync scope.
3. From a same-department workstation, attempt a new online domain sign-in: expect account disabled, not merely sign-in-method denied.
4. Run Delta sync and verify Entra Account enabled No.
5. Test new private-browser cloud sign-in: blocked.

Emma remains disabled. Later cleanup:
- ADUC → Emma → Member Of → remove GG_HR_Users; retain Domain Users.
- Microsoft 365 → Emma → Licenses and apps: confirmed Licenses (0), Sign-in blocked.
- New OU evidence shows Emma in HR/Users.
- Entra → Emma → Revoke sessions was instructed; explicit execution/audit confirmation remains pending.
- Data retention/hand-over and existing Windows/SMB/app session handling are not inferred from disablement or an empty license list.

Disabling does not instantly terminate every existing session. Full offboarding beyond the demonstrated account/access changes is not claimed.

## 12. Jamie's Microsoft 365 license and hybrid join

### License and Outlook

Microsoft 365 admin center → Users → Active users → Jamie → Licenses and apps:
1. Set valid Usage location if empty.
2. Assign Business Premium.
3. Confirm Exchange Online and Microsoft Intune services enabled.
4. Save; wait for service provisioning.
5. Private browser → https://outlook.office.com/mail/ → sign in as Jamie and open inbox.

The session verified Outlook access; external mail delivery and desktop-app installation were not tested.

### Hybrid join GUI configuration

On the DC/Connect server:
1. Microsoft Entra Connect → Configure → Customize synchronization options.
2. Confirm HR/Computers selected in Domain/OU Filtering; preserve user/pilot scope.
3. Finish, then Configure → Configure device options.
4. Authenticate authorized Entra administrator.
5. Configure Microsoft Entra hybrid join → Windows 10 or later domain-joined devices.
6. SCP: jh.test forest, Microsoft Entra ID authentication service, authorized Enterprise Admin credentials.
7. Configure and exit.

On HR-PC, open elevated Task Scheduler with local LabAdmin, while Jamie remains the ordinary signed-in user:
- Microsoft/Windows/Workplace Join → Automatic-Device-Join → Run.
- Allow the device registration attributes to be written.
- Run a Connect Initial cycle after a scope change; inspect Operations/export completion.
- Retry the task once synchronization is complete.
- Sign out/in as Jamie.

```powershell
# On the Connect server after a scope change.
Start-ADSyncSyncCycle -PolicyType Initial
```

Verify from Jamie's ordinary shell:
```powershell
whoami
dsregcmd /status | Select-String 'AzureAdJoined|DomainJoined|DeviceAuthStatus|AzureAdPrt|Mdm'
```

Expected: both join values YES, DeviceAuthStatus SUCCESS, AzureAdPrt YES. A Pending portal record alone is not completed hybrid join.

## 13. Intune automatic enrollment

### User eligibility and scope

Entra → Groups → assigned Security group SG-Intune-Pilot-Users; Jamie is a direct member.

Intune → Devices → Enrollment → Windows → Automatic Enrollment:
- Final MDM user scope All, intentionally retained by the owner.
- WIP scope None.
- Default MDM URLs, including discovery:
```text
https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc
```

All permits eligible users to autoenroll; it does not assign licenses, enroll every PC immediately, or expand a GPO link. The pilot user group still scopes compliance separately.

### GPO

Group Policy Management → HR/Computers → create/link GPO-HR-Intune-AutoEnrollment.

Edit:
```text
Computer Configuration
  Policies
    Administrative Templates
      Windows Components
        MDM
          Enable automatic MDM enrollment using default Microsoft Entra credentials
```

Older wording may say Azure AD. Set Enabled, User Credential. Leave MDM Application ID blank.

Client administrator:
```powershell
gpupdate /force
```

Sign out/in as Jamie. MFA interaction is conditional on authentication/policy; no prompt is not a failure.

### Enrollment verification

While signed in as Jamie, open Task Scheduler as administrator:
```text
Microsoft/Windows/EnterpriseMgmt
  Schedule created by enrollment client for automatically enrolling in MDM from AAD
```

If a registration attempt is already running, allow it to finish before checking the result.

Client Settings → Accounts → Access work or school → jh.test → Info:
- Organizational management server.
- Successful Sync result.

Intune → Devices → All devices → HR-PC-01:
- Managed by Intune.
- Primary user Jamie Morgan.
- Recent check-in.

Verify the hybrid identity from Jamie's ordinary PowerShell:
```powershell
dsregcmd /status | Select-String 'AzureAdJoined|DomainJoined|DeviceAuthStatus|AzureAdPrt|Mdm'
```

Final device and user identity were verified alongside the actual client management state and portal inventory.

## 14. HR compliance pilot

Preserve the earlier WIN-COMP-Sales-Bitlocker policy.

Intune → Devices → Compliance → Create policy:
- Platform Windows 10 and later.
- Name WIN-COMP-HR-Pilot.
- System Security: Firewall Require, Antivirus Require, Real-time protection Require.
- Other settings Not configured.
- Default immediate Mark device noncompliant action.
- Default scope tags.
- Assign SG-Intune-Pilot-Users.
- Review/create, client Sync, and inspect device/per-setting reports.

The owner reported Compliant for this policy. Compliance evaluates state; it does not itself turn on each protection. This result does not certify drive encryption.

An initial Default Device Compliance Policy row showed Has a compliance policy assigned / Error 65001, while active/enrolled-user checks passed. That was investigated separately from actual security settings. The tenant-wide no-policy behavior was not changed to force green status.

## 15. Intune login-banner configuration

Entra → Groups → create assigned Security group SG-Intune-Pilot-Devices. Add the actual HR-PC-01 device, not the Jamie user.

Intune → Devices → Configuration → Create/New policy:
- Windows 10 and later.
- Settings catalog.
- **Actual deployed name: IN-CONFIG-Pilot-LogonBanner.**

Add settings → search Interactive → Local Policies Security Options:
- Interactive Logon Message Title For Users Attempting To Log On.
- Interactive Logon Message Text For Users Attempting To Log On.

Values:
```text
Title: Junui Hong Lab
Text: Authorized lab users only. This device is managed by Junui Hong Lab.
```

Default scope tags; assign SG-Intune-Pilot-Devices; create.

Client Info → Sync, save work, restart. Confirm the pre-sign-in banner matches. Keep these settings out of GPO so delivery attribution remains clear.

Portal → profile → Device and user check-in status:
- Final captured result: Succeeded 1, Error 0, Conflict 0.
- Initial all-zero report followed the real client change. Wait for check-in/report refresh rather than recreating a working profile.

## 16. Restart validation and current operating checkpoint

Completed shutdown sequence: client → DC → router. Completed startup: router → DC/services → client. Use normal guest shutdown, including:
```bash
sudo shutdown -h now
```

After Ubuntu startup:
```bash
ip -br -4 addr
ip -4 route
sysctl net.ipv4.ip_forward
sudo iptables -t nat -S POSTROUTING
sudo systemctl status isc-dhcp-relay --no-pager
```

Captured results: six addressed UP NICs; default route via 10.0.0.2; forwarding 1; five retained source-subnet MASQUERADE rules; Relay enabled/active.

On the DC, inspect Services and DHCP scopes. The uploaded console shows all four scopes Active. A fresh full services/DC health/scheduler transcript was not supplied.

On HR-PC-01:
```powershell
ipconfig /all
Resolve-DnsName "_ldap._tcp.dc._msdcs.jh.test" -Type SRV
Test-NetConnection 192.168.1.2 -Port 445 -InformationLevel Quiet
Test-NetConnection 1.1.1.1 -Port 443 -InformationLevel Quiet
```

Captured HR lease: 192.168.0.194, mask 255.255.255.224, gateway 192.168.0.193, DHCP/DNS 192.168.1.2. DNS and both connection tests passed.

Check user tokens from Jamie's ordinary shell:
```powershell
whoami
dsregcmd /status | Select-String 'AzureAdJoined|DomainJoined|DeviceAuthStatus|AzureAdPrt'
```

Final captured identity: jh\\jamiemorgan; both joins YES; device authentication SUCCESS; PRT YES. Check the actual user context before interpreting PRT.

HR file access and Intune Info → Sync were reported healthy. The client was later restored again after the read-only test; final current state is HR/Computers, VMnet4, Jamie.

Do not roll back AD/hybrid-device snapshots casually during routine operations.

## 17. Employee inventory and license evidence

ADUC → Saved Queries → New → Query → Define Query → Custom Search → Advanced. Search jh.test with subtree coverage.

All department employees:
```text
(&(objectCategory=person)(objectClass=user)(|(department=HR)(department=Engineering)(department=Sales-Marketing)(department=IT)))
```

Enabled:
```text
(&(objectCategory=person)(objectClass=user)(|(department=HR)(department=Engineering)(department=Sales-Marketing)(department=IT))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
```

Disabled:
```text
(&(objectCategory=person)(objectClass=user)(|(department=HR)(department=Engineering)(department=Sales-Marketing)(department=IT))(userAccountControl:1.2.840.113556.1.4.803:=2))
```

Completed counts: 71 / 70 / 1. Disabled result is Emma. In ADUC, add Department and User Logon Name columns and use Export List to preserve the inventory. A final exported file is not yet committed.

These are AD Department-filtered people, not total Entra or baseline CSV counts.

Microsoft 365 → Active users → Emma → Licenses and apps:
- Sign-in blocked.
- Licenses (0).
- Business Premium showed 23 available out of 25 at capture time.

Current license absence does not establish that no historical data exists.

## 18. HR read-only test and cleanup

**Completed acceptance:** Nolan read HR content; original-file save, create and delete were denied. Temporary access cleanup and client restoration were owner-reported.

GUI setup:
1. As Jamie, create a small nonempty HR share text file. Record the actual extension; the captured test file had a doubled .txt extension because of filename entry.
2. ADUC → HR → New Group: actual name GG-HR-ReadOnly_Test, Global, Security.
3. Open that Global group's Members tab and add Nolan Allen. Retain Nolan's GG_IT_Users and Domain Users.
4. Open the **DL_HR_Share_Read group's Properties → Members** and add **GG-HR-ReadOnly_Test**, not Nolan directly. This is the group Members tab, not the user's Member Of tab.
5. Move the computer object temporarily to IT/Computers, keep the client NIC on HR VMnet4, apply policy as local LabAdmin, then sign out fully.
6. Sign in as JH\\nolanallen and verify whoami.
7. Access the HR share and run the matrix.

```text
Nolan -> GG-HR-ReadOnly_Test -> DL_HR_Share_Read -> SMB Read / NTFS RX
```

| Operation | Expected and captured outcome |
|---|---|
| Open existing file and read contents | Allowed |
| Edit and save back to the original shared path | Denied |
| Create a new shared item | Denied |
| Delete an existing shared file | Denied |

A local Save As copy is not a failed read-only restriction. The original shared path must reject the write.

Cleanup:
1. DL_HR_Share_Read → Members: remove GG-HR-ReadOnly_Test.
2. Test Global group → Members: remove Nolan; preserve the empty group if retaining the scenario.
3. Sign out/in as Nolan and verify HR share access is revoked.
4. Restore computer object to HR/Computers; VMnet4 remains.
5. As LabAdmin run gpupdate /force; sign out and restore Jamie.

Cleanup/restoration was reported successful; no final membership export was supplied. No SMB/NTFS ACL was broadened to make the test pass.

## 19. Company Portal deployment — next action

**Not yet verified.** Instructions were issued, but assignment, client installation and portal Installed status have not been confirmed.

1. Intune → Apps → All apps → Company Portal. Reuse an existing Microsoft Store app (new) object if present.
2. If absent: Create → Microsoft Store app (new) → search Company Portal, publisher Microsoft Corporation.
3. App information: Install behavior System.
4. Assignments → Required: add SG-Intune-Pilot-Devices, preserving any existing Sales assignments.
5. Save/create. Keep Jamie signed in; run client Info → Sync and allow installation/check-in time.
6. Do not install manually from Store while testing automatic delivery.
7. Confirm Windows Start → Company Portal exists and launches; sign in as Jamie.
8. Intune app → Device install status: HR-PC-01 Installed.

Acceptance requires both real app availability/launch and Intune installation reporting. Creating the app object or assigning a group alone is not completion.

After this, continue the approved ACL, BitLocker/LAPS, backup/restore and additional network stages in the integration plan.

## Official references

- [Windows DHCP setup](https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/quickstart-install-configure-dhcp-server)
- [Local console logon right](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/allow-log-on-locally)
- [Hybrid join](https://learn.microsoft.com/en-us/entra/identity/devices/how-to-hybrid-join)
- [GPO autoenrollment](https://learn.microsoft.com/en-us/windows/client-management/enroll-a-windows-10-device-automatically-using-group-policy)
- [Intune enrollment scope](https://learn.microsoft.com/en-us/intune/device-enrollment/windows/enable-automatic-mdm)
- [Windows compliance settings](https://learn.microsoft.com/en-us/intune/device-security/compliance/ref-windows-settings)
- [Settings catalog](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/)
- [Company Portal app deployment](https://learn.microsoft.com/en-us/intune/app-management/deployment/add-company-portal-autopilot)
