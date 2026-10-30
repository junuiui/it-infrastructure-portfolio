# IT Infrastructure Portfolio

A 70-employee company lab covering network design, on-premises identity, hybrid identity, and departmental file services.

**Current result:** 70 AD employee accounts synchronized to Microsoft Entra ID using Connect Sync. One pilot user's cloud sign-in and AD-to-Entra job-title update were verified. Four department shares have configured SMB and NTFS permissions; client access testing is pending.

## Documentation

- [How-to Guide](HowTo.md) — network setup, AD users, Connect Sync, groups, shares, verification, and shutdown.
- [Problems and Resolutions](ProblemSolving.md) — DNS failure, unresolved Cloud Sync timeout, pilot password issue, and client preparation blocker.
- [Company Specification](company-spec.md) — fixed Packet Tracer addressing and the implemented VMware environment.
- [Integration Plan](integration-plan.md) — completed work, evidence limits, and remaining acceptance checks.
- [2026-10-30 Session Record](progress-2026-10-30.md) — today's changes and the exact restart point.
- [AD Resources](resources/AD/readme.md) — employee CSV and existing scripts.
- [Network References](resources/Network/readme.md) — original design sources.

All repository documentation and code comments are written in English.

## Project layers

| Layer | Project | Current integration status |
|---|---|---|
| Network | [Network Infrastructure Lab](https://github.com/junuiui/network-infrastructure-lab) | Fixed design reference; Packet Tracer is unchanged |
| On-premises identity | [Original AD Homelab](https://github.com/junuiui/homelab) and the separate jh.test lab | Original lab preserved; jh.test contains the new workforce and department shares |
| Cloud identity / endpoint | [M365, Entra & Intune Lab](https://github.com/junuiui/m365-entra-intune-lab) | Employee synchronization verified with Connect Sync; new-workforce M365/Intune tests remain |

## Company workforce

| Department | Employees |
|---|---:|
| HR | 8 |
| Engineering | 35 |
| Sales-Marketing | 22 |
| IT | 5 |
| **Total** | **70** |

HR maps to the original Network lab's HR/Finance organization. The lab uses representative devices, not 70 client VMs or a 70-client load test.

## Verified and pending results

| Area | Result |
|---|---|
| Entra directory | Screenshot shows 72 active user objects: 70 employees, one administrator, and the retained Sales object |
| Synchronization status | Pilot on-premises attributes shown; owner reported the 70-user synced filter and export checks passed |
| Pilot sign-in | Owner reported successful cloud authentication after resetting Emma's AD password |
| Attribute update | Screenshot shows Emma's job title changed to HR Coordinator |
| Scheduled sync | Owner reported enabling the Connect Sync scheduler |
| File services | Supplied output confirms four shares, explicit SMB/NTFS ACLs, and Access-Based Enumeration |
| Employee share access | **Not yet tested** from a client |
| GPO / workstation logon restrictions | **Pending** in the integration AD |
| Department DHCP / relay | **Pending** in VMware |
| Cloud Sync | **Unresolved** WebSocket timeout; disabled in favor of Connect Sync |
| M365 / Intune | New-workforce licensing, mailbox, enrollment, and policy validation remain |

![Entra directory showing 72 active user objects](resources/photos/01-72-users-sync.png)

![Emma's updated job title in Entra](resources/photos/00-emma-wilson-job-title-changed.png)

The first image supports directory population, not successful sign-in for every employee. The second supports a pilot attribute update, not endpoint compliance.

## Integration boundaries

- **Packet Tracer and VMware share a design.** They do not form one physically connected lab.
- **AD and Entra are actually synchronized** using Connect Sync.
- **User sync, Windows domain/Entra join, and Intune enrollment are separate operations.**
- Existing cloud-only test employees were deleted by the owner; their data and device relationships were not migrated to the new employees.
- Cloud Sync and Connect Sync must not process the same users concurrently.

## Next session

Prepare a Windows 11 Pro/Enterprise client with a known local administrator, connect it to the isolated lab, join jh.test, and test HR share access as Emma plus denied access to other departments. Preserve the existing Entra-joined Intune VM.

The new win-lab client attempt is incomplete: the owner reported an incorrect image and plans to reinstall. Its join state and edition have not been verified.
