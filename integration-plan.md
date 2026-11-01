# Integration Plan

[README](README.md) · [How-to Guide](HowTo.md) · [Company Specification](company-spec.md) · [October 31 Record](progress-2026-10-31.md)

## Objective and current result

Integrate the original network, AD, and M365 labs using one company model. Preserve the Packet Tracer baseline and original projects while recording actual integration evidence here.

**Core functional integration completed on October 31, 2026.** Four department networks, identity/resource controls, lifecycle scenarios, cloud services, hybrid join, Intune enrollment, compliance, and one delivered configuration profile were tested. Expanded-router restart persistence, the HR client restart checks, employee counts and HR read-only acceptance have subsequently passed. Group/session/data records and the next implementation stages remain.

## Original six-step roadmap

| Step | Result | Remaining boundary |
|---|---|---|
| 1. Align departments, workforce, and addresses | Original 70-person specification adopted | AD counts confirmed 71 objects / 70 enabled / one disabled; archival export still needed |
| 2. Prepare AD pilot and validate AD/DNS | AD users, pilot, DNS repair, and connectivity verified | Full fresh DC health transcript not captured |
| 3. Test sync and login before expansion | Connect Sync, pilot login, and title update passed | Original Cloud Sync timeout unresolved; investigation optional |
| 4. Expand identity, groups, GPO, and shares | Four department roles, console restrictions, resource operations, and JML tested | HR Read tested; other Read groups and exhaustive access matrix remain |
| 5. Implement network/DHCP/DNS | Four department data VMnets, routing, DHCP scopes, Relay and Internet tests passed | Router/HR restart checks passed; network ACLs not implemented |
| 6. Integrate cloud services/endpoints | Jamie licensed/Outlook tested; hybrid join, Intune, compliance, banner delivery passed | New-workforce app deployment and broader service tests optional |

## Acceptance record

### Network

- [x] Preserve the Packet Tracer addressing baseline.
- [x] Create server VMnet3 and upstream VMnet8 router path.
- [x] Create HR/ENG/SM/IT data VMnets 4/5/6/7.
- [x] Map Ubuntu interfaces by MAC and configure gateway addresses.
- [x] Configure four Active Windows DHCP scopes with AD DNS.
- [x] Relay DHCP to 192.168.1.2 and add outbound NAT.
- [x] Test each department sequentially with the representative client.
- [x] Return the client to HR/VMnet4 and confirm Ava sign-in.
- [x] Reboot the expanded stack; capture all router interfaces, NAT, forwarding and automatic Relay startup; verify HR connectivity and hybrid identity.
- [x] Capture the HR post-restart lease: 192.168.0.194/27, gateway 192.168.0.193, DHCP/DNS 192.168.1.2.
- [ ] Archive exact ENG/SM/IT lease/export evidence if required; only their earlier functional tests were reported.

### AD, workstation, and file access

- [x] Create the baseline employees, department OUs, GG/DL resource groups and four shares.
- [x] Retain a known local administrator on the new Windows 11 Pro client.
- [x] Join HR-PC-01 to jh.test.
- [x] Create four department computer OUs and scoped console-logon GPOs.
- [x] Test own-department login/file operations and the instructed cross-department denials.
- [x] Keep administrator console access available.
- [ ] Capture final membership counts and nested group evidence after lifecycle changes.
- [x] Test HR Read using Nolan: read allowed, original save/create/delete denied; cleanup and restoration owner-reported.
- [ ] Extend Read testing to other departments only if needed for the final access matrix.

### Employee lifecycle

- [x] Joiner Jamie: AD creation, HR group/resource access, Entra sync and cloud sign-in.
- [x] Mover: Engineering-to-HR attribute/OU/group change, access transition and restoration reported.
- [x] Leaver Emma: disabled AD login, disabled Entra state and blocked new cloud sign-in.
- [ ] Confirm whether Revoke sessions was executed.
- [x] Remove Emma from GG_HR_Users, retain Domain Users and confirm zero current M365 licenses.
- [ ] Confirm session revocation, retained-data disposition, and existing-session handling before claiming full offboarding.
- [x] Confirm department-filtered AD employee counts: 71 objects, 70 enabled, one disabled (Emma).
- [ ] Commit/archive the inventory export and reconcile total Entra/nonemployee objects separately.

A disabled account is not proof that all existing sessions, permissions, licenses, or retained data were handled.

### Hybrid identity and Microsoft 365

- [x] Verify Connect Sync user flow and AD-to-Entra job-title update.
- [x] Preserve Cloud Sync failure evidence and disable that engine for overlapping scope.
- [x] Verify ADSync Running and object scheduler enabled at the session start.
- [x] Include the client computer OU in device sync scope and configure hybrid join/SCP.
- [x] Verify DomainJoined YES, AzureAdJoined YES, DeviceAuthStatus SUCCESS and Jamie PRT YES.
- [x] Assign Jamie Business Premium and verify Outlook web access.
- [x] Inspect license snapshot: Emma has zero licenses; Business Premium available 23 of 25.
- [ ] Capture total tenant inventory and the current scheduled-sync state.

### Intune

- [x] Verify Intune service/license, active tenant and MDM authority.
- [x] Configure automatic MDM enrollment using User Credential.
- [x] Retain final MDM scope All intentionally; WIP None.
- [x] Confirm Intune portal device and Jamie primary user.
- [x] Assign WIN-COMP-HR-Pilot and receive owner-reported Compliant result.
- [x] Deliver IN-CONFIG-Pilot-LogonBanner to the device pilot group.
- [x] Verify real Windows banner and final portal Succeeded 1 / Error 0 / Conflict 0.
- [ ] Capture final per-setting compliance report; the old default-policy 65001 row was not separately shown as cleared.

MDM scope All is not a license assignment, an autoenrollment GPO link, or a compliance-policy assignment. Each is controlled separately.

## Closeout order

1. Preserve evidence and update English docs/GUI How-to — this update.
2. Clean shutdown/startup and HR client validation completed; retain evidence without rolling back joined-device snapshots.
3. Router/interfaces/scopes, HR DHCP/DNS/connectivity and hybrid state verified; resource and Intune checks owner-reported healthy. Broader DC/scheduler exports can be archived separately.
4. Employee query counts confirmed; archive exports and final memberships.
5. Emma HR access-group removal and zero licenses confirmed; verify session/data steps.

No percentage is assigned: acceptance results and limits are more useful than a blended completion number.

## Next implementation stages — approved for follow-up

- [ ] Company Portal via Microsoft Store app (new), Required to SG-Intune-Pilot-Devices: instructions issued; assignment, installation, Jamie launch and Installed report not yet confirmed.
- [ ] Interdepartmental network ACLs based on the fixed PT design, with representative reachability tests and administrator recovery.
- [ ] HR BitLocker, recovery-key escrow and LAPS validation.
- [ ] Backup and restore validation.
- [x] HR read-only access and temporary-access restoration test.
- [ ] Larger access matrix if needed.
- [ ] Extend voice, guest and Wi-Fi implementation from the fixed PT design, with explicit acceptance checks and documented platform limitations.
- Further Cloud Sync root-cause analysis remains optional.

The owner requested completion of the remaining work after the core integration. Implement these stages sequentially and retain acceptance evidence. None is marked complete before testing. Further Cloud Sync investigation remains optional because Connect Sync already meets the identity objective.

## Reporting rules

Documentation and comments remain English. Distinguish screenshots/output, owner-reported outcomes, inferred counts, and pending checks. Prefer GUI for Windows administration. Preserve baseline CSV/scripts and historical records.

Do not claim direct Packet Tracer-to-VMware connectivity, 802.1Q implementation, network packet isolation from file-permission denials, all-user testing, or a proven cause for the original Cloud Sync failure.
