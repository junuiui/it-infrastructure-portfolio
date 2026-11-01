# Evidence Index

[README](../../README.md) · [October 31 Record](../../progress-2026-10-31.md)

Screenshots are supplied by the lab owner. The table states what each image supports; account/file names alone are not proof of the active identity.

| File | What it supports | Limit |
|---|---|---|
| [00 — Pilot title update](00-emma-wilson-job-title-changed.png) | AD-to-Entra job-title test | Historical pilot, before Emma was disabled |
| [01 — 72-user directory](01-72-users-sync.png) | October 30 directory population | Not a current post-Jamie count or all-user sign-in test |
| [02 — HR share open](02-hr-share-open.png) | HR share is reachable and browsable | Visible old 0KB file does not prove new create/edit/delete operations |
| [03 — Cross-department share denied](03-cross-department-share-denied.png) | Explicit permission denial for ENG share in the HR test sequence | Does not show packet isolation or the complete access matrix |
| [06 — Four DHCP scopes](06-four-active-dhcp-scopes.png) | HR/ENG/SM/IT scopes Active | Scope ranges/options and exact leases were reported separately |
| [07 — Intune device overview](07-intune-device-overview.png) | Corporate/Intune device, HR-PC-01, primary user Jamie | Captured before explicit HR compliance assignment; badge/report disagreement visible |
| [08 — Management sync](08-intune-management-sync.png) | Client management server and successful sync | Does not prove every policy or app applied |
| [09 — Login banner](09-intune-logon-banner.png) | Actual Windows display matches the assigned text/title | Portal success is recorded separately |
| [10 — Profile success](10-intune-logon-banner-report.png) | IN-CONFIG-Pilot-LogonBanner reports Succeeded 1, errors/conflicts 0 | One representative device |
| [11 — Router interfaces/routes](11-network1.png) | Six addressed NICs and the single default route after restart | Router evidence, not an endpoint test on every subnet |
| [12 — Retained forwarding/NAT/Relay](12-network2.png) | Forwarding 1, five NAT rules and enabled/active Relay after restart | Guest log times are retained as captured; unrelated command typo is not a configuration failure |
| [13 — AD department OUs/users](13-AD-OU-users.png) | Four department computer/user OU structures; Emma and Jamie in HR/Users | Does not show full employee counts or effective memberships |
| [14 — DHCP scopes after restart](14-AD-DHCP-scope.png) | Four Windows scopes Active | Not a full lease export |
| [15 — HR lease and DNS](15-jh_test-HRPC01-ipconfig.png) | HR-PC-01 at 192.168.0.194/27; gateway .0.193; DHCP/DNS .1.2; SRV resolution | Captures HR, not individual ENG/SM/IT leases |
| [16 — Nolan reads HR](16-readonly-nolan-read.png) | whoami Nolan and readable nonempty HR file | Read result only; separate images show write restrictions |
| [17 — Original save denied](17-readonly-save-denied.png) | Nolan cannot save changes to the original shared file | A local Save As copy is a different operation |
| [18 — New item denied](18-readonly-create-denied.png) | Nolan cannot create an item in HR share | No packet isolation inference |
| [19 — Delete denied](19-readonly-delete-denied.png) | Nolan cannot delete an existing HR file | File owner prompt does not grant that owner administrator rights |
| [20 — Company Portal installed notification](20-company-portal-install-notification.png) | Intune software-distribution notification reports successful installation | Portal reporting verified separately |
| [21 — Company Portal running](21-company-portal-running.png) | Organizational app session, HR-PC-01 and Can access company resources | Empty Available-app catalog does not indicate deployment failure |
| [22 — Company Portal Installed report](22-company-portal-installed-report.png) | HR-PC-01/Jamie, Installed, version 11.2.2044.0 | Guest/portal timestamps are kept as captured |


Numbering leaves space for additional evidence; no missing image file is referenced.

## Transcript-only / not committed as image evidence

- Ava, Luke, Nora and Nolan department acceptance results.
- Mover result/restoration; name of the mover not recorded.
- Emma disabled-account Windows error and disabled Entra/cloud sign-in test.
- Jamie AD/cloud sign-in, Business Premium and Outlook success.
- Final hybrid/PRT diagnostic output and the post-restart Jamie check, supplied in chat.
- WIN-COMP-HR-Pilot Compliant result, reported by the owner.
- Inventory Saved Query counts confirmed by the owner: 71 employee objects / 70 enabled / one disabled. The exported inventory file is not committed.
- Emma HR group removal and zero licenses are shown in chat screenshots, not committed here as separate images.
- Final read-only membership cleanup/access revocation and HR client restoration are owner-reported; no final group export.

No raw diagnostic archive, password, token, or private key is committed. Selected screenshots include normal lab tenant/device/user identifiers.
