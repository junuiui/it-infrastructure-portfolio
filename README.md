# IT Infrastructure Portfolio

## Summary

A hybrid IT infrastructure lab built from one company design: four department networks, on-premises Active Directory, Microsoft Entra ID, Microsoft 365, and Intune.

I provisioned a 70-person workforce, tested department access, connected AD identities to Entra, and managed a hybrid-joined Windows client. I also configured Windows LAPS and BitLocker with recovery information stored in AD and Entra.

## Why I built this

I first built [Network Infrastructure](https://github.com/junuiui/network-infrastructure-lab), [AD Homelab](https://github.com/junuiui/homelab), and [M365 / Entra / Intune](https://github.com/junuiui/m365-entra-intune-lab) as separate projects.

I wanted to connect them into one IT infrastructure lab. Instead of testing each service alone, I used one company model to see how IP addressing, DNS, user accounts, permissions, and device management work together.

The original Packet Tracer design stays unchanged. VMware follows its department addressing; the two platforms are separate.

## What I built and tested

```text
Packet Tracer: department addressing and network design
                         |
                  VMware implementation
                         |
Ubuntu router — HR / Engineering / Sales-Marketing / IT
  NAT + DHCP Relay       |
                         +— Windows Server: AD DS + DNS + DHCP + file shares
                                      |
                               Entra Connect Sync
                                      |
                              Microsoft Entra ID
                                      |
                              Microsoft 365 / Intune

HR-PC-01: AD joined + Entra hybrid joined + Intune managed
          Windows LAPS + BitLocker
```

| Area | Work and result |
|---|---|
| Network services | Four department subnets, Windows DHCP scopes, Ubuntu DHCP Relay and NAT. DHCP, AD DNS, server access, and Internet connectivity tested in each department. |
| Identity | Created 70 synthetic employees from CSV. Added Jamie as a joiner and retained Emma as a disabled leaver: 71 employee objects, 70 enabled, one disabled at the recorded inventory check. |
| Access control | Department groups, AGDLP file permissions, and workstation logon GPOs. Tested own-department access, cross-department denial, and temporary read-only access. |
| Hybrid identity | Connect Sync with Password Hash Synchronization. Verified hybrid join, device authentication, and Jamie's PRT. |
| Cloud management | Jamie's Microsoft 365 access, Intune enrollment, compliance, login banner, and automatic Company Portal installation. |
| Windows LAPS | Managed local `LabAdmin`, stored its password in AD, retrieved it as an administrator, tested its use, and rotated it. |
| BitLocker | Intune required encryption; a GPO configured recovery backup. Verified C: fully encrypted, Protection On, and recovery records in AD and Entra. |

One Windows client was reused for department tests. The final client is **HR-PC-01**, on the HR network, with **Jamie Morgan** as its Intune primary user.

### Selected evidence

- [Department DHCP scopes](resources/photos/14-AD-DHCP-scope.png) and [HR lease / AD DNS](resources/photos/15-jh_test-HRPC01-ipconfig.png)
- [Cross-department share denied](resources/photos/03-cross-department-share-denied.png)
- [Read-only access](resources/photos/16-readonly-nolan-read.png) and [write denied](resources/photos/17-readonly-save-denied.png)
- [Intune login banner](resources/photos/09-intune-logon-banner.png) and [Company Portal Installed report](resources/photos/22-company-portal-installed-report.png)
- [LAPS password stored in AD](resources/photos/23-laps-ad-backup-success.png)
- [BitLocker fully encrypted / Protection On](resources/photos/24-bitlocker-encrypted.png) and [AD recovery record](resources/photos/25-bitlocker-ad-recovery-record.png)

See the [Evidence Index](resources/photos/readme.md) for screenshot coverage and session-reported results.

## Problems and solutions

### 1. AD DNS failed after a network change

The DC was using home-network DNS servers, so AD locator records could not resolve. I moved it to the isolated server network, assigned a static IP, and used the DC's DNS service with external forwarders. AD DNS and connectivity checks then passed.

### 2. Cloud Sync timed out

Cloud Sync on-demand provisioning failed even after DNS repair, endpoint checks, agent diagnostics, and reinstallation. I used Connect Sync to test the same AD and tenant. User synchronization and cloud sign-in worked, so Connect Sync became the working engine. The original Cloud Sync root cause remains unresolved.

### 3. BitLocker policy success did not mean encryption success

The client first detected the Windows installation ISO. After disconnecting it, recovery policy blocked AD backup. The corrected Intune recovery settings did not appear on the client. I kept Intune's encryption settings and applied recovery settings through an AD GPO. Encryption then reached 100% with Protection On.

Full symptoms, approaches, reasons, and verification: [Problem-solving](ProblemSolving.md).

## Limitations

- VM resources limited the lab to one representative Windows client. Department tests were sequential; I did not test 70 concurrent devices.
- VMware VMnets represent department networks. This is not an implemented 802.1Q trunk, and interdepartmental network ACLs are outside this version. File and logon denials are identity controls.
- The DC also hosts DHCP and file shares. This reduces VM use but combines roles that could be separated in a larger deployment.
- Voice, guest Wi-Fi, printers, and the simulated web server remain in the Packet Tracer design.
- Cloud Sync's timeout and Intune's recovery-policy delivery issue were bypassed, not proven fixed. The working configuration is documented.
- Backup and restore testing is excluded. BitLocker recovery-key storage is verified; a forced recovery boot is not.
- The mover test passed by session report, but its account name and before/after evidence were not saved. Offboarding session revocation has no saved audit evidence. A final combined regression after the security changes has not been recorded.

## Documentation

| Document | Use |
|---|---|
| [How-to](HowTo.md) | Build the working configuration, then verify each stage |
| [Problem-solving](ProblemSolving.md) | What failed, why each approach was used, and what resolved it |
| [Company specification](company-spec.md) | Address plan, workforce, interfaces, and policy scope |
| [Scope and validation](integration-plan.md) | Delivered scope, exclusions, and evidence boundaries |
| [Phase 1](phase-1.md) | AD preparation and hybrid identity |
| [Phase 2](phase-2.md) | Department networks, access and device management |
| [Phase 3](phase-3.md) | LAPS, BitLocker and documentation |
| [Evidence index](resources/photos/readme.md) | Available screenshots and what they prove |
| [AD resources](resources/AD/readme.md) | Baseline CSV and provisioning scripts |

Phase 1 and Phase 2 record the earlier build checkpoints. The current scope is defined here and in the scope document.
