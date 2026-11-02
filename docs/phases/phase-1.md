# Phase 1 — AD and Hybrid Identity

[README](../../README.md) · [Phase 2](phase-2.md) · [How-to](../../how-to.md)

## Goal

Use the fixed Packet Tracer company design to build a separate AD environment and verify a cloud identity pilot before expanding it.

## Work completed

- Created jh.test without replacing the original homelab.
- Provisioned 70 synthetic employees from the baseline CSV: HR 8, Engineering 35, Sales-Marketing 22, IT 5.
- Used lowercase firstnamelastname account names and the tenant UPN suffix.
- Placed the DC on the isolated server subnet at 192.168.1.2/28, with AD DNS and Ubuntu upstream routing.
- Investigated Cloud Sync timeout, then selected Connect Sync with Password Hash Synchronization.
- Tested Emma's cloud sign-in and an AD-to-Entra job-title change.
- Expanded synchronization to department users.
- Configured department Global/Domain Local groups and four SMB shares.

## Validation

| Check | Recorded result |
|---|---|
| AD accounts | 70 baseline users created |
| DNS/connectivity | DNS passed by report; gateway and TCP 443 tests passed |
| Cloud pilot | Emma cloud sign-in and title synchronization passed |
| Workforce sync | Historical Entra view showed 72 objects, including nonemployee objects |
| Shares | SMB and NTFS output matched the intended Modify/Read tiers |

The 72-object view is a historical tenant snapshot, not the later department-filtered employee count.

## Decisions and boundaries

Cloud Sync remained disabled because on-demand provisioning timed out. Connect Sync met the identity objective; the original failure cause was not confirmed.

The existing Entra-only client had no usable administrator credentials. It was preserved, and a separate Windows Pro client was prepared. Functional client/share tests continued in Phase 2.

## Continue

- [Phase 2](phase-2.md): department networks, workstation access, lifecycle and Intune.
- [Company specification](../company-spec.md): addresses and naming.
- [How-to](../../how-to.md): setup instructions.
- [Problem-solving](../../problem-solving.md): DNS, Cloud Sync and client decisions.
