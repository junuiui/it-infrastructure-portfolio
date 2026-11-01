# Integration Plan

[README](README.md) · [How-to Guide](HowTo.md) · [Company Specification](company-spec.md) · [October 31 Record](progress-2026-10-31.md)

## Objective and current result

Integrate the original network, AD, and M365 labs using one company model. Preserve the Packet Tracer baseline and original projects while recording actual integration evidence here.

**Core functional integration completed on October 31, 2026.** Four department networks, identity/resource controls, lifecycle scenarios, cloud services, hybrid join, Intune enrollment, compliance, and one delivered configuration profile were tested. Final restart persistence and inventory reconciliation remain closeout tasks.

## Original six-step roadmap

| Step | Result | Remaining boundary |
|---|---|---|
| 1. Align departments, workforce, and addresses | Original 70-person specification adopted | Jamie/Emma lifecycle changes require a current inventory separate from the CSV |
| 2. Prepare AD pilot and validate AD/DNS | AD users, pilot, DNS repair, and connectivity verified | Full fresh DC health transcript not captured |
| 3. Test sync and login before expansion | Connect Sync, pilot login, and title update passed | Original Cloud Sync timeout unresolved; investigation optional |
| 4. Expand identity, groups, GPO, and shares | Four department roles, console restrictions, resource operations, and JML tested | Read-only groups and exhaustive user/access matrix not tested |
| 5. Implement network/DHCP/DNS | Four department data VMnets, routing, DHCP scopes, Relay and Internet tests passed | Final expanded-stack restart; network ACLs not implemented |
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
- [ ] Reboot the fully expanded stack and capture all-interface, NAT, forwarding and Relay persistence.
- [ ] Archive exact final lease/export evidence; individual lease values were not supplied.

### AD, workstation, and file access

- [x] Create the baseline employees, department OUs, GG/DL resource groups and four shares.
- [x] Retain a known local administrator on the new Windows 11 Pro client.
- [x] Join HR-PC-01 to jh.test.
- [x] Create four department computer OUs and scoped console-logon GPOs.
- [x] Test own-department login/file operations and the instructed cross-department denials.
- [x] Keep administrator console access available.
- [ ] Capture final membership counts and nested group evidence after lifecycle changes.
- [ ] Test Read DL groups if a read-only tier is included in the final project scope.

### Employee lifecycle

- [x] Joiner Jamie: AD creation, HR group/resource access, Entra sync and cloud sign-in.
- [x] Mover: Engineering-to-HR attribute/OU/group change, access transition and restoration reported.
- [x] Leaver Emma: disabled AD login, disabled Entra state and blocked new cloud sign-in.
- [ ] Confirm whether Revoke sessions was executed.
- [ ] Define/complete leaver group cleanup, license/data handover, and existing-session handling if claiming full offboarding.
- [ ] Capture current inventory: baseline 70 + Jamie, retained disabled Emma, enabled and nonemployee counts separately.

A disabled account is not proof that all existing sessions, permissions, licenses, or retained data were handled.

### Hybrid identity and Microsoft 365

- [x] Verify Connect Sync user flow and AD-to-Entra job-title update.
- [x] Preserve Cloud Sync failure evidence and disable that engine for overlapping scope.
- [x] Verify ADSync Running and object scheduler enabled at the session start.
- [x] Include the client computer OU in device sync scope and configure hybrid join/SCP.
- [x] Verify DomainJoined YES, AzureAdJoined YES, DeviceAuthStatus SUCCESS and Jamie PRT YES.
- [x] Assign Jamie Business Premium and verify Outlook web access.
- [ ] Capture a final tenant inventory/license snapshot and current scheduled-sync state.

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
2. Perform a clean shutdown/startup test without rolling back joined-device snapshots.
3. Verify all router interfaces, scopes/Relay, DC DNS, scheduled sync, HR sign-in, file access, Intune check-in and banner.
4. Export current inventory and memberships; record enabled versus retained disabled employee objects.
5. Decide whether to finish Emma's offboarding beyond the demonstrated disable/sync/block test.

No percentage is assigned: acceptance results and limits are more useful than a blended completion number.

## Optional extensions

- Win32/Store app deployment to the pilot.
- Interdepartmental network ACLs and representative reachability tests.
- HR BitLocker, recovery-key escrow and LAPS validation.
- Backup and restore validation.
- Read-only access tests and a larger access matrix.
- Voice, guest and Wi-Fi implementation beyond Packet Tracer.
- Further Cloud Sync root-cause analysis.

These are separate extensions, not uncompleted claims hidden inside the core integration.

## Reporting rules

Documentation and comments remain English. Distinguish screenshots/output, owner-reported outcomes, inferred counts, and pending checks. Prefer GUI for Windows administration. Preserve baseline CSV/scripts and historical records.

Do not claim direct Packet Tracer-to-VMware connectivity, 802.1Q implementation, network packet isolation from file-permission denials, all-user testing, or a proven cause for the Cloud Sync/initial MDM URL failures.
