# Phase 3 — LAPS, BitLocker and Documentation

[README](../../README.md) · [Phase 2](phase-2.md) · [Validation](../validation.md)

## Goal

Add local administrator password management and disk encryption, then close the documentation scope.

## Windows LAPS

- Updated the DC to obtain the built-in Windows LAPS module.
- Prepared AD schema and self-write permission on HR/Computers.
- Applied GPO-HR-Windows-LAPS to existing local LabAdmin: encrypted AD storage, 20-character password, 30-day age.
- Verified event 10018, authorized DC-side retrieval, actual use of the managed credentials and password rotation.
- Confirmed updated rotation metadata and successful decryption. A second credential-use test after final rotation was not separately saved.

## BitLocker

- Intune delivered the encryption requirement and silent standard-user settings.
- Disconnected the installation ISO after the client error identified bootable media.
- Investigated blocked AD recovery backup and missing corrected Intune recovery settings.
- Kept Intune encryption settings and moved recovery configuration to GPO-HR-BitLocker-Recovery.
- Verified GPO values 1/1/1, C: 100% encrypted, XTS-AES 128 and Protection On.
- Confirmed an AD recovery record and key presence in Intune/Entra.

The corrected Intune recovery-policy delivery issue remains unexplained. The split policy is the working solution; it is not evidence that Intune cannot manage recovery settings.

## Final scope

Backup/restore and network ACL implementation were excluded. No forced BitLocker recovery boot, BitLocker noncompliance/Conditional Access test or fresh combined regression is claimed.

The [How-to](../../how-to.md) holds the final build sequence, [Problem-solving](../../problem-solving.md) holds investigations, and [Validation](../validation.md) holds results and evidence limits. Passwords and recovery passwords are not published.
