# Validation Record

[README](../README.md) · [How-to](../how-to.md) · [Problem-solving](../problem-solving.md)

**Current scope.** This document replaces the earlier open-ended implementation roadmap. Phase records retain the decisions and validation boundaries from each build stage.

## Objective

Connect the existing Network Infrastructure, AD and M365 labs through one company design. Keep the Packet Tracer source and original homelab unchanged.

## Delivered scope

| Area | Recorded result |
|---|---|
| Four data networks | HR, Engineering, Sales-Marketing, IT; Windows DHCP, AD DNS, Ubuntu Relay/NAT; sequential department tests passed |
| AD workforce | 70 baseline CSV users; Jamie added; Emma retained disabled; last confirmed employee counts 71 / 70 enabled / 1 disabled |
| Authorization | Department AGDLP shares and logon GPOs; own-share and cross-department tests; HR read-only test |
| Lifecycle | Joiner passed; mover change/restoration reported without saved identity/before-after evidence; leaver disabled and department access removed |
| Hybrid identity | Connect Sync/PHS, AD-to-Entra attribute test, hybrid device join, successful device authentication and Jamie PRT |
| Microsoft 365 | Jamie licensed and Outlook web access reported successful |
| Intune | Enrollment, primary user Jamie, HR compliance, login banner and Company Portal delivery |
| Windows LAPS | AD password backup, authorized retrieval/use and rotation verified in Phase 3 |
| BitLocker | Intune encryption plus GPO recovery; C: 100%, Protection On; AD/Entra recovery records verified in Phase 3 |

## Final management boundaries

- GPO-HR-Windows-LAPS: HR/Computers; existing local LabAdmin; AD backup, encrypted storage, length 20, age 30 days.
- IN-ENC-HR-BitLocker: SG-Intune-Pilot-Devices; encryption requirement, warning suppression, standard-user enablement only.
- GPO-HR-BitLocker-Recovery: HR/Computers; recovery password and AD backup required before encryption.
- IN-ENC-HR-Recovery: no device pilot assignment in the final configuration.
- Existing HR compliance policy checks Firewall, Antivirus and Real-time protection. Its green result is not a BitLocker compliance test.
- MDM scope All remains intentional; enrollment GPOs and policy groups remain scoped independently.

## Excluded from this version

- Backup/restore implementation and restore testing, removed from scope by the owner.
- Interdepartmental network ACL implementation.
- Additional Windows client VMs and concurrent 70-device capacity testing.
- VMware deployment of the Packet Tracer voice, guest/Wi-Fi, printer and web services.
- Forced BitLocker recovery boot, encryption suspension/noncompliance and Conditional Access blocking.
- Further Cloud Sync or Intune recovery-policy root-cause investigation.

These are boundaries, not required tasks blocking this version.

## Evidence and closeout boundaries

The final combined regression after the Phase 3 security changes has not been recorded. The repeatable check matrix is below.

Existing results must not be expanded into untested claims:
- The mover account identity and before/after evidence were not saved.
- Temporary read-only cleanup was reported; no final membership export was committed.
- Emma's session revocation was instructed, but no explicit execution/audit evidence was supplied. Data retention is not established by zero assigned licenses.
- Final employee/tenant/group inventory exports and some cloud/compliance screenshots are not committed.
- LAPS retrieval/use was tested before the final rotation; the new metadata confirms rotation, not a separately recorded second credential-use test.
- BitLocker directory records exist; a forced recovery boot and saved matching-ID evidence across both directories were not supplied.

## Final verification matrix

This is the checklist for a fresh build or later change. It is not a claim that all checks were repeated together after Phase 3.

| Check | Where / method | Expected |
|---|---|---|
| Router | ip -br -4 addr; routes; forwarding; NAT; Relay | Six NICs, one default route, forwarding 1, five NAT rules, Relay active |
| DC/DNS | dcdiag, AD SRV lookup, DHCP console | Review test results; four active data scopes |
| Sync | ADSync service/scheduler and Synchronization Service Manager | Running, scheduler enabled, successful relevant exports |
| Client | ipconfig /all; DNS/SMB/HTTPS checks from section 16 | HR lease, AD DNS, working server and outbound access |
| Hybrid identity | dsregcmd /status as Jamie, not elevated as another account | Both joins YES, DeviceAuthStatus SUCCESS, AzureAdPrt YES |
| Authorization | Jamie own-share file operations; cross-department UNC test | HR allowed, unauthorized shares denied |
| Test cleanup | ADUC nested groups | Nolan has no direct or temporary HR Read grant |
| Leaver | AD/Entra Emma; administrator session-revocation action/audit | Disabled, department access removed; record revocation separately |
| Intune | Client Info Sync and actual policy/app reports | Management sync success; inspect each result rather than one overview badge |
| LAPS | DC metadata; event 10018 | LabAdmin, recent rotation, successful authorized decryption |
| BitLocker | manage-bde -status C: and directory records | 100%, Protection On, recovery record in AD/Entra |


## Current documents

README is the recruiter-facing overview. How-to is the working build/runbook. Problem-solving preserves investigation decisions and unresolved causes. Company Specification holds the addresses and policy scopes. Phase 3 is the security checkpoint; Phase 1 and Phase 2 record the earlier build stages.
