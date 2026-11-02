# Company Specification

**Current configuration.** The tables retain the original 70-person design and distinguish implemented data networks from simulation-only services.

[README](README.md) · [How-to Guide](HowTo.md) · [Integration Plan](integration-plan.md)

## Authority and implementation status

The existing Packet Tracer lab is the fixed network design reference. Its files and addressing are not changed for this integration.

- [Final network configuration](https://github.com/junuiui/network-infrastructure-lab/blob/main/HowTo.md)
- [Original headcount plan](https://github.com/junuiui/network-infrastructure-lab/blob/69d8c1a8993dfd07d1f167922214b5a84aa0ceb9/docs/architecture.md)

The tables below distinguish the full design from the smaller VMware implementation. A design entry is not evidence that a corresponding VM service has been deployed.

## Workforce and naming

| Department | Original organization | Network label | Employees |
|---|---|---|---:|
| HR | HR/Finance | HR | 8 |
| Engineering | Engineering | ENG | 35 |
| Sales-Marketing | Sales/Marketing | S/M or SM | 22 |
| IT | IT | IT | 5 |
| **Total** | | | **70** |

- AD domain: jh.test; base DN: DC=jh,DC=test.
- DC: WIN-9TRC5DR3JHV.jh.test.
- SamAccountName: lowercase firstnamelastname, without a prefix or separator.
- Employee UPN: firstnamelastname@junuihonglab.onmicrosoft.com.
- CSV: FirstName, LastName, Department, PositionName.
- PositionName maps to the AD Title property.
- Device naming target: HR-PC-01 / ENG-PC-01 / SM-PC-01 / IT-PC-01. Only HR-PC-01 is deployed for this integration. It was moved between department networks/OUs for sequential testing and is now back in HR.
- Same-name conflicts require review; the current script skips existing account-name/UPN conflicts rather than resolving them.
- Keep administrator, service, and resource objects separate from the 70-person employee count.

Existing cloud-only test employees were removed. The Phase 1 screenshot of 72 active directory objects is historical: 70 employees plus administrator and Sales objects. In Phase 2, Jamie Morgan was added in HR and Emma Wilson was retained but disabled. ADUC Saved Queries subsequently confirmed 71 employee objects, 70 enabled and one disabled (Emma). A final total Entra export has not been captured. Neither directory-object count nor employee count is a licensed-mailbox count.

The CSV remains the original 70-person baseline (HR 8 / ENG 35 / SM 22 / IT 5). Jamie is outside that CSV, so scripts/inventory checks must account for the additional user and disabled status.

## Packet Tracer VLAN and gateway design

| Network | VLAN | Subnet | Gateway |
|---|---:|---|---|
| HR Data | 10 | 192.168.0.192/27 | 192.168.0.193 |
| HR Voice | 110 | 192.168.0.224/27 | 192.168.0.225 |
| ENG Data | 20 | 192.168.0.0/26 | 192.168.0.1 |
| ENG Voice | 120 | 192.168.0.64/26 | 192.168.0.65 |
| S/M Data | 30 | 192.168.1.64/26 | 192.168.1.65 |
| S/M Voice | 130 | 192.168.1.128/26 | 192.168.1.129 |
| IT Data | 40 | 192.168.1.16/28 | 192.168.1.17 |
| IT Voice | 140 | 192.168.1.32/28 | 192.168.1.33 |
| Server | 50 | 192.168.1.0/28 | 192.168.1.1 |
| Guest | 99 | 192.168.1.192/26 | 192.168.1.193 |
| Staff Wi-Fi | 60 | 192.168.2.0/25 | 192.168.2.1 |

## Packet Tracer DHCP reference

| Pool | Lease range | Mask | Gateway |
|---|---|---|---|
| HR-Data | 192.168.0.194–192.168.0.219 | 255.255.255.224 | 192.168.0.193 |
| ENG-Data | 192.168.0.2–192.168.0.59 | 255.255.255.192 | 192.168.0.1 |
| S/M-Data | 192.168.1.66–192.168.1.125 | 255.255.255.192 | 192.168.1.65 |
| IT-Data | 192.168.1.18–192.168.1.27 | 255.255.255.240 | 192.168.1.17 |
| HR-Voice | 192.168.0.226–192.168.0.254 | 255.255.255.224 | 192.168.0.225 |
| ENG-Voice | 192.168.0.66–192.168.0.125 | 255.255.255.192 | 192.168.0.65 |
| S/M-Voice | 192.168.1.130–192.168.1.190 | 255.255.255.192 | 192.168.1.129 |
| IT-Voice | 192.168.1.34–192.168.1.46 | 255.255.255.240 | 192.168.1.33 |
| Guests | 192.168.1.194–192.168.1.254 | 255.255.255.192 | 192.168.1.193 |
| Staff-WiFi | 192.168.2.10–192.168.2.119 | 255.255.255.128 | 192.168.2.1 |
| serverPool | 192.168.1.6 only | 255.255.255.240 | 192.168.1.1 |

- Data/Staff DNS: 192.168.1.2.
- Guest DNS: 203.0.113.10, a simulated external server.
- Voice DNS: 0.0.0.0; phone TFTP: 192.168.1.4.
- serverPool is a Packet Tracer default-pool workaround, not a required Windows DHCP scope.
- Pool capacity is not employee headcount.
- Four Windows data scopes and the Ubuntu DHCP Relay were implemented and tested with one representative client in Phase 2.
- Voice, guest, Wi-Fi, printer, and web-server entries remain design/simulation references.

## Fixed addresses and service boundaries

| Item | Packet Tracer address | VMware implementation |
|---|---|---|
| DHCP/DNS server | 192.168.1.2/28 | AD DS, DNS, DHCP, and lab department file shares run on this Windows Server |
| Web server | 192.168.1.3/28 | Not deployed as part of this session |
| Voice/CME router | 192.168.1.4/28 | Packet Tracer only |
| Server gateway | 192.168.1.1 | Ubuntu internal NIC |
| HR printer | 192.168.0.221/27 | Design reference only |
| ENG printer | 192.168.0.62/26 | Design reference only |
| S/M printer | 192.168.1.126/26 | Design reference only |
| IT printer | 192.168.1.30/28 | Design reference only |
| HR switch management | 192.168.0.220/27 | Design reference only |
| IT switch management | 192.168.1.28/28 | Design reference only |

The Packet Tracer internal record is intranet.fakecompany.test → 192.168.1.3. Its external server 203.0.113.10 is not a real upstream Internet resolver.

AD requires its own domain and DC locator records. Copying a Packet Tracer web A record does not implement AD DNS.

## Implemented VMware server network

| Component | Configuration |
|---|---|
| Host physical LAN | 192.168.1.0/24, overlapping the design server subnet |
| VMnet3 | Internal 192.168.1.0/28; no host adapter; VMware DHCP disabled |
| VMnet8 | NAT 10.0.0.0/24; gateway 10.0.0.2; VMware DHCP and host adapter disabled |
| Ubuntu router | lab-router; Ubuntu Server 24.04.5 LTS |
| Router WAN | ens33, VMnet8, 10.0.0.10/24, default route via 10.0.0.2 |
| Router LAN | ens34, VMnet3, 192.168.1.1/28, no separate default route |
| DC NIC | VMnet3, 192.168.1.2/28 |
| DC gateway / DNS | 192.168.1.1 / 192.168.1.2 |
| DNS forwarders | 1.1.1.1 and 8.8.8.8 |
| Router forwarding / NAT | IPv4 forwarding and ens33 MASQUERADE for 192.168.1.0/28 |

The host adapter is disabled on VMnet3 to avoid adding an overlapping lab interface to the host. Outbound traffic passes through Ubuntu NAT and then VMnet8 NAT. The expanded router subsequently passed the restart check: six interfaces, one default route, forwarding 1, five NAT rules and enabled/active DHCP Relay were captured.

## Implemented department networks

| Network | VMnet | Ubuntu NIC | MAC suffix | Router address | DHCP pool |
|---|---|---|---|---|---|
| HR | 4 | ens38 | :8e | 192.168.0.193/27 | 192.168.0.194–219 |
| ENG | 5 | ens39 | :98 | 192.168.0.1/26 | 192.168.0.2–59 |
| SM | 6 | ens40 | :a2 | 192.168.1.65/26 | 192.168.1.66–125 |
| IT | 7 | ens41 | :ac | 192.168.1.17/28 | 192.168.1.18–27 |

These VMnets have host virtual adapters and VMware DHCP disabled. The Ubuntu router has six NICs in total, including WAN ens33 and server ens34. Interface names were confirmed against MAC addresses.

- Single default route: via 10.0.0.2 on ens33.
- IPv4 forwarding enabled.
- MASQUERADE on ens33 for the server subnet and all four department data subnets.
- DHCP server: 192.168.1.2; DNS: 192.168.1.2; suffix: jh.test.
- Relay interfaces: ens38 ens34 ens39 ens40 ens41; WAN excluded.
- Current client: HR-PC-01 on VMnet4, IPv4/DNS automatic.
- 192.168.1.10/28 was the temporary server-segment client address used before departmental DHCP. It is not the final client configuration.
- Windows GUI is preferred for DHCP, AD, GPO, and device administration; Ubuntu uses Netplan and terminal commands.

### Test identities

| Department role | Employee | Outcome |
|---|---|---|
| HR | Ava Collins | DHCP/connectivity and HR resource access; final return to HR confirmed |
| ENG | Luke Fisher | Department network, GPO, file access and tested cross-department denial passed |
| SM | Nora Green | Department network, GPO, file access and tested cross-department denial passed |
| IT | Nolan Allen | Department network, GPO, file access and tested cross-department denial passed |

The same PC was used sequentially. The HR post-restart lease is captured as 192.168.0.194/27; exact ENG/SM/IT leases and simultaneous client operation were not captured.

## Identity and file-service design

- Current sync tool: Microsoft Entra Connect Sync with Password Hash Synchronization.
- Cloud Sync configuration remains disabled; its timeout is unresolved.
- Sync scope: HR, Engineering, Sales-Marketing, IT, and Entra-Pilot, including selected employee OUs and HR/Computers for hybrid device synchronization.
- Emma is retained but disabled in both AD and Entra. The new ADUC evidence shows her in HR/Users. GG_HR_Users was removed; Domain Users remains. Current M365 licenses: zero.
- Jamie Morgan is an additional HR/Users joiner, Title HR Assistant, with HR group access, a Business Premium license, cloud sign-in, and Outlook web access.
- Department Global Security Groups: GG_HR_Users, GG_ENG_Users, GG_SM_Users, GG_IT_Users.
- Resource Domain Local Security Groups: DL_CODE_Share_Modify and DL_CODE_Share_Read.
- Intended membership: Accounts → department Global group → resource Domain Local group → permission.
- HR Read was tested temporarily using Nolan and GG-HR-ReadOnly_Test. Read was allowed; original-file save, create and delete were denied. Temporary membership cleanup was owner-reported; final nested-membership counts were not exported.
- Department shares are hosted on the DC for this lab.

| Share | Path | NTFS Modify / SMB Change | NTFS Read & Execute / SMB Read |
|---|---|---|---|
| HR$ | C:\LabShares\HR | DL_HR_Share_Modify | DL_HR_Share_Read |
| ENG$ | C:\LabShares\ENG | DL_ENG_Share_Modify | DL_ENG_Share_Read |
| SM$ | C:\LabShares\SM | DL_SM_Share_Modify | DL_SM_Share_Read |
| IT$ | C:\LabShares\IT | DL_IT_Share_Modify | DL_IT_Share_Read |

SYSTEM and Administrators retain NTFS Full Control. Administrators have SMB Full access. All four shares show AccessBased enumeration. Department employees tested own-share file operations and cross-department denials. The HR Read tier was subsequently tested with Nolan; other department Read groups were not separately tested.

## Scope limits

VMnet separation is not evidence of an 802.1Q trunk/VLAN implementation. Packet Tracer remains separate. User sync does not automatically join a Windows device or enroll it in Intune.

The original Intune VM remains separate. The new HR-PC-01 is Windows 11 Pro, AD joined, Microsoft Entra hybrid joined, and Intune managed. User sync alone did not establish this state; SCP/device synchronization and an autoenrollment GPO were configured separately.

## Workstation and cloud policy scope

| Policy/group | Purpose / scope |
|---|---|
| GPO-HR-Workstation-Logon | HR/Computers; Administrators + GG_HR_Users allowed locally |
| GPO-ENG-Workstation-Logon | Engineering/Computers; Administrators + GG_ENG_Users |
| GPO-SM-Workstation-Logon | Sales-Marketing/Computers; Administrators + GG_SM_Users |
| GPO-IT-Workstation-Logon | IT/Computers; Administrators + GG_IT_Users |
| GPO-HR-Intune-AutoEnrollment | HR/Computers; Enabled, User Credential |
| SG-Intune-Pilot-Users | Assigned security user group containing Jamie |
| WIN-COMP-HR-Pilot | Windows compliance: Firewall, Antivirus, Real-time protection required; assigned to pilot users |
| SG-Intune-Pilot-Devices | Assigned security device group containing HR-PC-01 |
| IN-CONFIG-Pilot-LogonBanner | Settings catalog; title/text banner; assigned to pilot devices |
| WIN-COMP-Sales-Bitlocker | Pre-existing Sales policy, preserved separately |

Final MDM user scope is **All** by owner choice, WIP scope **None**. This enables automatic enrollment for eligible users, not immediate enrollment of every AD computer. The GPO is linked only to HR/Computers; other department PCs require an appropriate link and device/user prerequisites.

Primary user: Jamie Morgan. Final hybrid/device authentication and PRT were verified. The HR compliance policy reported Compliant. The banner was visible on Windows and its final portal summary showed one successful device with zero errors/conflicts.

Department logon GPOs use computer OU placement. Group membership controls the allowed user population and file permissions. A user's OU or Department field alone does not grant access.

Company Portal, restart persistence and HR Read acceptance were verified before the security extension. Windows LAPS and BitLocker were verified in Phase 3. Network ACLs and backup/restore are excluded from the final scope; the earlier implementation plan is superseded.

## Later validation checkpoint

- HR-PC-01 lease: 192.168.0.194/27, gateway 192.168.0.193, DHCP/DNS 192.168.1.2.
- Jamie post-restart identity: DomainJoined YES, AzureAdJoined YES, DeviceAuthStatus SUCCESS, AzureAdPrt YES.
- HR share and Intune Sync were reported healthy after restart and subsequent computer-OU restoration.
- Inventory: 71 employee objects / 70 enabled / one disabled.
- Microsoft 365 license view: Emma unlicensed; Business Premium showed 23 available out of 25 at capture time.
- Current client placement after read-only testing: HR/Computers, VMnet4; Jamie restored by owner report.
- Company Portal deployment: Microsoft Store app (new), System context, Required to SG-Intune-Pilot-Devices. Client success notification and live app were captured; Intune reports HR-PC-01 Installed, Jamie UPN, version 11.2.2044.0.
- Company Portal displays HR-PC-01 and Can access company resources. No optional self-service apps were published to Jamie at capture time.

## Phase 3 security configuration

| Component | Final setting / source |
|---|---|
| GPO-HR-Windows-LAPS | HR/Computers; existing local LabAdmin; AD backup; password encryption enabled; 20 characters; 30 days |
| LAPS retrieval | Authorized Domain Admin on the DC; no employee password-read delegation |
| IN-ENC-HR-BitLocker | Pilot device group; Require Device Encryption Enabled, Allow Warning For Other Disk Encryption Disabled, Allow Standard User Encryption Enabled |
| Intune OS recovery options | Not configured in the encryption profile |
| IN-ENC-HR-Recovery | Standalone trial profile; pilot assignment removed for the final configuration |
| GPO-HR-BitLocker-Recovery | HR/Computers; 48-digit recovery password required; AD backup of password and key package required before enablement |
| Drive result | C: Fully Encrypted, 100%, XTS-AES 128, Protection On; TPM and Numerical Password protectors |
| Recovery records | AD child record observed; Entra/Intune key presence confirmed |
| Backup and restore | Excluded; no file/system-state backup or restore acceptance claimed |

The DC required Windows updates before the Windows LAPS module became available. LAPS event 10018, password retrieval/use and rotation were verified. The final rotation confirmed a new update time and a 30-day expiry.

The installation ISO had to be disconnected before silent BitLocker encryption. The corrected Intune recovery settings were not observed on the client; the recovery GPO applied values 1/1/1 and encryption then completed. The delivery issue's root cause remains unconfirmed.

These results do not establish a new combined network/cloud regression, forced recovery boot, or BitLocker compliance/Conditional Access test. Keep the original CSV, addresses, and historical records unchanged.
