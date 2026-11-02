# Phase 3 — LAPS, BitLocker and Documentation

[README](README.md) · [How-to](HowTo.md) · [Problem-solving](ProblemSolving.md)

## Scope decision

The final version covers existing test cleanup, Windows LAPS, BitLocker, final verification and documentation. Backup/restore was explicitly removed from scope. Network ACLs and extra VMware network services are also excluded.

## Windows LAPS — verified

- Updated Windows Server 2022; LAPS commands became available.
- Prepared AD schema and computer self-write permission on HR/Computers.
- Created GPO-HR-Windows-LAPS for existing local LabAdmin.
- Used AD backup, password encryption, length 20 and age 30 days.
- Captured event 10018: AD password update succeeded.
- Queried from the DC as a domain administrator; local LabAdmin was not an AD query identity.
- Retrieved the password privately and successfully used it on HR-PC-01.
- Ran Reset-LapsPassword; metadata showed a new update and Success.
- Rotation metadata confirmed an updated password and a 30-day expiry.
- No managed password is published. Use after the final rotation was not separately captured.

## BitLocker — verified

Initial state: Fully Decrypted, 0%, no protectors. TPM ready; WinRE enabled.

1. Created IN-ENC-HR-BitLocker with the three silent-encryption settings.
2. Disconnected bootable installation ISO after the detailed BitLocker error identified it.
3. Observed AD recovery-backup policy error; original values were 0/0/2.
4. Revised Intune recovery settings, retried delivery, and trialed a separate recovery profile.
5. Corrected recovery settings were not observed on the client. Local management Sync succeeded, but reports/payload evidence did not establish their delivery.
6. Removed separate profile assignment and left Intune recovery options Not configured.
7. Configured GPO-HR-BitLocker-Recovery on HR/Computers.
8. gpupdate produced 1/1/1; encryption then progressed to completion.
9. Captured Fully Encrypted, 100%, XTS-AES 128, Protection On; protectors TPM and Numerical Password.
10. AD recovery child record observed; owner confirmed a key in the Intune/Entra view.

The final split is Intune encryption requirement plus AD GPO recovery settings. The Intune recovery-delivery root cause remains unconfirmed. A forced recovery boot and BitLocker noncompliance/Conditional Access test were not performed.

## Documentation

- README rewritten for Hiring Managers/Recruiters: summary, motivation, implementation/results, three representative problems, limitations.
- How-to expanded with prerequisites, fresh forest/router setup, Windows LAPS and the final BitLocker configuration.
- Problem-solving records approaches, reasons, results and unresolved causes.
- Company Specification, scope document, AD resource notes and evidence index aligned.
- Earlier phase records retain their original validation boundaries.

## Verification boundary

No new full regression was supplied after the security changes. Earlier cleanup was reported for temporary read access; Emma revocation has no saved execution/audit evidence. Missing evidence is not marked complete. No backup disk, backup job, or restore test is claimed.
