# Phase 2 — Networks, Access and Device Management

[README](../../README.md) · [Phase 1](phase-1.md) · [Phase 3](phase-3.md)

## Goal

Connect the department address plan, AD access controls and cloud device management on a representative Windows client.

## Work completed

- Installed Windows 11 Pro, created local LabAdmin, joined jh.test and used HR-PC-01.
- Created department Computers OUs and logon GPOs.
- Added HR/ENG/SM/IT VMnets, router NICs, Windows DHCP scopes, DHCP Relay and NAT.
- Tested department roles by moving the same client between VMnets and computer OUs.
- Tested joiner, mover and leaver scenarios.
- Verified Jamie's Microsoft 365 access, hybrid join, Intune enrollment and primary-user association.
- Delivered a compliance policy, login banner and Company Portal.
- Verified router persistence and the HR client's connectivity after restart.
- Tested temporary HR read-only access with Nolan, then reported cleanup and restoration to HR/Jamie.

## Validation

| Area | Recorded result |
|---|---|
| HR / Ava Collins | Department network and resource tests passed |
| ENG / Luke Fisher | Department network and resource tests passed |
| SM / Nora Green | Department network and resource tests passed |
| IT / Nolan Allen | Department network and resource tests passed |
| Read-only role / Nolan | HR read allowed; original-path save, create and delete denied |
| Joiner / Jamie | AD/group access, Entra sync, cloud sign-in and Outlook access passed |
| Mover | Engineering-to-HR change and restoration reported; identity and before/after record missing |
| Leaver / Emma | AD/Entra disabled, HR group removed, no assigned M365 licenses |
| Employee query | 71 objects: 70 enabled, one disabled |
| Hybrid identity | DomainJoined YES, AzureAdJoined YES, DeviceAuthStatus SUCCESS, Jamie PRT YES |
| Intune | Managed client; Jamie primary user; HR compliance reported Compliant |
| Banner | Visible on Windows; profile Succeeded 1, Error/Conflict 0 |
| Company Portal | Automatic install, organizational app launch and Installed report |
| Restart | Six router NICs, one default route, forwarding, five NAT rules and active Relay retained |

The exact captured HR lease was 192.168.0.194/27, gateway 192.168.0.193, DHCP/DNS 192.168.1.2. Exact ENG/SM/IT leases were not saved.

## Decisions and boundaries

One client was reused sequentially; these results are not concurrent multi-client tests. SMB/logon denials are identity authorization, not network ACL isolation.

The original CSV remains 70 users. Jamie is additional; Emma remains retained and disabled. Temporary access cleanup was reported without a final membership export. Emma's session revocation has no saved execution/audit evidence.

## Continue

[Phase 3](phase-3.md) covers LAPS and BitLocker. Use the [validation record](../validation.md) for evidence boundaries and the [evidence index](../../resources/photos/README.md) for screenshots. Network ACLs, backup/restore and extra Packet Tracer services are outside the final scope.
