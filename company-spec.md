# Company Specification

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
- Device naming target: HR-PC-01 / ENG-PC-01 / SM-PC-01 / IT-PC-01. These names are not all deployed.
- Same-name conflicts require review; the current script skips existing account-name/UPN conflicts rather than resolving them.
- Keep administrator, service, and resource objects separate from the 70-person employee count.

Existing cloud-only test employees were removed. The current Entra directory has 72 active user objects: 70 synchronized employees, Junui administrator, and the retained Sales account object. This is not a count of licensed mailboxes.

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
- Windows departmental scopes and relay have not yet been verified in VMware.

## Fixed addresses and service boundaries

| Item | Packet Tracer address | VMware implementation |
|---|---|---|
| DHCP/DNS server | 192.168.1.2/28 | AD DC and DNS use this address; Windows DHCP deployment is pending |
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

The host adapter is disabled on VMnet3 to avoid adding an overlapping lab interface to the host. Outbound traffic passes through Ubuntu NAT and then VMnet8 NAT. NAT persistence across a router restart still needs confirmation.

A proposed test client address is 192.168.1.10/28 on VMnet3, gateway 192.168.1.1, DNS 192.168.1.2. This is a representative server-segment client, not an implemented HR Data VLAN. Confirm address availability before assignment.

## Identity and file-service design

- Current sync tool: Microsoft Entra Connect Sync with Password Hash Synchronization.
- Cloud Sync configuration remains disabled; its timeout is unresolved.
- Sync scope: HR, Engineering, Sales-Marketing, IT, and Entra-Pilot, including the selected employee child OUs.
- Emma remains in Entra-Pilot with Department = HR.
- Department Global Security Groups: GG_HR_Users, GG_ENG_Users, GG_SM_Users, GG_IT_Users.
- Resource Domain Local Security Groups: DL_CODE_Share_Modify and DL_CODE_Share_Read.
- Intended membership: Accounts → department Global group → resource Domain Local group → permission.
- Read groups are intended to remain empty until a read-only requirement is tested. Membership counts/nesting were not supplied as final captured output.
- Department shares are hosted on the DC for this lab.

| Share | Path | NTFS Modify / SMB Change | NTFS Read & Execute / SMB Read |
|---|---|---|---|
| HR$ | C:\LabShares\HR | DL_HR_Share_Modify | DL_HR_Share_Read |
| ENG$ | C:\LabShares\ENG | DL_ENG_Share_Modify | DL_ENG_Share_Read |
| SM$ | C:\LabShares\SM | DL_SM_Share_Modify | DL_SM_Share_Read |
| IT$ | C:\LabShares\IT | DL_IT_Share_Modify | DL_IT_Share_Read |

SYSTEM and Administrators retain NTFS Full Control. Administrators have SMB Full access. All four shares show AccessBased enumeration. Actual employee access and cross-department denial remain untested.

## Scope limits

VMnet separation is not evidence of an 802.1Q trunk/VLAN implementation. Packet Tracer remains separate. User sync does not automatically join a Windows device or enroll it in Intune.

The original Intune VM is Entra joined and not AD-domain joined. Preserve it. A new win-lab client installation needs correction before AD-domain join and GPO tests.
