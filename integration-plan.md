# Integration Plan

[README](README.md) · [Company Specification](company-spec.md) · [How-to Guide](HowTo.md)

## Objective

Connect the existing network design, on-premises AD work, and M365/Entra/Intune work into one company scenario. The original projects remain visible as foundations; this repository records the integration and its evidence.

The Packet Tracer design remains unchanged. VMware reproduces selected design elements, not a physical connection to the simulation.

## Status as of October 30, 2026

| Original step | Current status | Remaining work |
|---|---|---|
| 1. Confirm departments, 70-person allocation, and addressing | Complete as a specification | Implement remaining VMware department segments |
| 2. Prepare AD pilot and validate AD/DNS | Complete for pilot preparation and DNS check | Retain broader DC health and post-reboot evidence |
| 3. Verify Entra sync and pilot login first | Complete with Connect Sync | Cloud Sync cause remains unresolved; no requirement to restore it |
| 4. Expand OUs, users, groups, GPO, logon limits, file permissions | Users/groups/shares configured | Client access, group membership evidence, GPO, and logon tests pending |
| 5. Align VMware IP, DHCP, DNS and retest | Server segment/router/DNS complete | Router persistence, department subnets, DHCP scopes, relay and lease evidence |
| 6. Reconcile existing cloud users and validate M365/Intune | Old test users removed and 70 employees synced | New-workforce licenses, mailbox/service and endpoint tests |

The work is not assigned an overall percentage: configuring an ACL, testing an employee's access, and validating endpoint management are different acceptance gates.

## Completed work

- [x] Preserve the original Homelab AD; use the separate jh.test domain for integration.
- [x] Adopt fixed Packet Tracer addressing and department totals: 8 / 35 / 22 / 5.
- [x] Create the 70-person CSV and AD employee accounts.
- [x] Use lowercase firstnamelastname account names.
- [x] Configure the tenant UPN suffix and align employee UPNs.
- [x] Place Emma in Entra-Pilot and keep her HR department attribute.
- [x] Implement the VMnet3 server segment and Ubuntu-to-VMnet8 outbound routing.
- [x] Correct the DC's DNS configuration; owner reported the DNS test passed.
- [x] Investigate Cloud Sync and retain its unresolved status.
- [x] Use Connect Sync with Password Hash Synchronization for the pilot.
- [x] Resolve Emma's temporary-password state and verify her cloud sign-in.
- [x] Observe an AD job-title update in Entra.
- [x] Remove the old cloud-only test employees while retaining administrator and Sales objects.
- [x] Expand sync scope and observe the 72-user directory.
- [x] Configure departmental GG/DL groups and four shares; verify supplied share/NTFS ACL output.
- [x] Identify the client preparation blocker without disconnecting the existing Intune VM.
- [x] Update the integration documentation in English.

Group setup is recorded from the owner's progression through the procedure. Final direct membership counts still need captured verification.

## Gate A — Functional on-premises client

- [ ] Reinstall win-lab with verified Windows 11 Pro/Enterprise media.
- [ ] Establish a known local administrator and verify it before identity changes.
- [ ] Verify edition and dsregcmd state.
- [ ] Place the representative client on VMnet3 with correct gateway and AD DNS.
- [ ] Join jh.test and verify domain membership.
- [ ] Verify GG user counts and GG-to-DL nesting, including Emma in HR.
- [ ] Confirm Emma can create, read, edit, and delete in HR$.
- [ ] Confirm Emma is denied ENG$, SM$, and IT$.
- [ ] Test the empty read groups with a designated temporary test assignment if needed, then remove that assignment.
- [ ] Retain screenshots or transcripts showing the test identity and outcome.

Do not interpret a successful SMB test as proof of workstation logon restriction.

## Gate B — GPO and lifecycle

- [ ] Create appropriate client computer OUs and place the client correctly.
- [ ] Build scoped client GPOs; keep ordinary employee restrictions off the DC.
- [ ] Test same-department logon and cross-department denial with representative workstation/user pairs.
- [ ] Record gpresult /r or equivalent resultant policy evidence.
- [ ] Joiner: create a designated test user, apply groups, and verify expected resource/cloud access.
- [ ] Mover: change a designated user's department and remove old access before confirming new access.
- [ ] Leaver: disable a designated test user and validate the resulting access/sign-in controls.
- [ ] Keep synchronization scope stable during OU moves; scope removal can delete the cloud object.

## Gate C — Network implementation

- [ ] Confirm IPv4 forwarding and NAT survive a router reboot.
- [ ] Retest DC DNS and outbound HTTPS after startup.
- [ ] Plan VMware network mapping for the remaining department subnets.
- [ ] Implement routing and any relay needed between representative subnets and DHCP.
- [ ] Deploy Windows DHCP and matching data scopes/exclusions/options.
- [ ] Verify a client lease, gateway, DNS, and scope selection on each implemented segment.
- [ ] Record which Packet Tracer voice, guest, and Wi-Fi elements remain simulation-only.

Do not create 70 PCs to represent 70 directory users. Representative clients are sufficient for functional tests; they do not prove full-load performance.

## Gate D — M365 and endpoint management

- [ ] Select a limited test cohort and verify current license availability before assignment.
- [ ] Confirm cloud sign-in for representative employees; the other 69 were not individually tested.
- [ ] Validate intended M365 service/mailbox behavior for licensed test users.
- [ ] Preserve and document the old Entra-joined Intune device separately.
- [ ] Choose the intended join/enrollment model for each new test device.
- [ ] Validate Intune enrollment, policy application, and compliance for the selected device.
- [ ] Verify group-based behavior explicitly; AD user sync does not grant licenses or local administrator rights.

## Next-session sequence

1. Fix client installation and administrator access.
2. Verify local domain/network connectivity.
3. Run positive and negative file-access tests.
4. Implement and test GPO/logon restrictions.
5. Continue departmental network services and M365/Intune validation.

Connect Sync remains the selected integration tool. Further Cloud Sync investigation is optional and must not interrupt the working identity path.

## Evidence and documentation rules

- Write documentation and code comments in English.
- Label work as verified, owner-reported, configured but untested, or planned.
- Preserve the fixed Network Infrastructure baseline and the original Homelab history.
- Record test user, source client, expected result, actual result, and evidence.
- Never publish passwords, tokens, private keys, or unreviewed diagnostic archives.
- Keep unresolved causes explicit; do not turn a successful workaround into a claimed root-cause fix.
