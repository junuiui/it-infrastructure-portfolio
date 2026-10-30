# Problems and Resolutions

[README](README.md) · [How-to Guide](HowTo.md) · [Session Record](progress-2026-10-30.md)

This document separates symptoms, evidence, actions, and outcomes. No unverified cause is presented as a resolution.

## 1. DC DNS and connectivity diagnosis failed

**Symptoms:** dcdiag could not resolve the DC GUID under _msdcs.jh.test, reported no LDAP connectivity, invalid DNS servers, and missing DC record registration. The NIC was using a dynamic address and DNS servers 192.168.1.254 / 75.153.176.9.

**Action:** Put the DC on isolated VMnet3 at 192.168.1.2/28, use the actual router 192.168.1.1, point NIC DNS to the DC itself, configure external forwarders, and re-register host/DC records.

**Verification:** Gateway Ping 4/4 and outbound TCP 443 succeeded. The owner reported DNS test passed. Full Advertising/Services/Connectivity results are not all archived.

**Limit:** This fixed a real DNS misconfiguration but did not resolve Cloud Sync timeout.

## 2. Cloud Sync on-demand timeout — unresolved

**Scope:** One pilot, CN=Emma Wilson,OU=Entra-Pilot,DC=jh,DC=test. The cloud configuration stayed disabled while on-demand was used. Agent version observed: 1.1.2507.0.

**Symptom:** The portal reported a target-response timeout. Provisioning logs remained empty across attempts. Agent service Running and portal Active did not prove successful user processing.

### Investigation

| Approach | Observation / outcome |
|---|---|
| On-demand identifier | Initial ObjectGUID guidance was wrong; switched to Distinguished Name per Microsoft documentation, but timeout remained |
| AD/DNS repair | DNS test subsequently passed; timeout remained |
| General connectivity | DC could reach an external TCP 443 target |
| Actual cloud endpoint | ServiceBus HTTPS HEAD returned an HTTP response without bypassing certificate validation; this does not test authenticated WebSocket traffic |
| Proxy inspection | WinHTTP reported Direct access; other proxy/security paths were not fully excluded |
| Agent restart | WebSocket failures continued |
| Verbose diagnostic collection | Request arrived via Relay and ACK was returned; follow-up WebSocket connection failed |
| Folder write issue | Created missing Endpoints directory, verified inherited gMSA rights and endpoints.txt creation; timeout remained |
| Agent reinstall | Reinstalled and registered the agent; same timeout reported |
| Connect Sync comparison | Same AD and tenant successfully synchronized the pilot and then all 70 employees |

### Decisive trace sequence

On October 30, 2026, at approximately 11:24 AM America/Vancouver:

```text
Client request received via Relay
Returning Ack
Establishing web socket connection (Timeout: 30000 ms)
Web socket failed to connect
```

Other errors included forced connection closure and ServiceBusClientWebSocket EOF. This rules out the blanket statement that no cloud request reached the agent. It does not identify which endpoint or intermediate component caused the later failure.

### Additional local errors

```text
Unable to load DLL 'pap_connector_lib.dll'
Unable to initialize performance counters
Access to ...\Provisioning Agent\Endpoints is denied
```

The DLL error occurred in Event Viewer initialization. A search did not find that DLL under the installed agent directory. These observations do not establish that the DLL error caused the WebSocket timeout.

The Endpoints parent ACL granted the service gMSA inherit-only rights. After an administrator created the directory, its inherited ACL applied to the directory itself, and the agent saved endpoints.txt. The provisioning failure remained.

A sensor configuration fallback and disposal exceptions were also logged. They were not promoted to root-cause findings.

### Current decision

Keep Cloud Sync disabled and its service stopped. Use Connect Sync for the project. Do not run both engines against the same user population.

Double NAT, TLS inspection, gMSA key binding, and a tenant backend issue remain hypotheses, not confirmed causes. The timeout predates the Ubuntu double-NAT setup. A TCP reset does not by itself prove a NAT failure. Encrypted packet capture cannot expose HTTP 101 or WebSocket payloads without appropriate decryption material.

A Connect Sync success narrows the failure to a different execution path; it does not prove the exact Cloud Sync root cause or explain the empty portal logs.

## 3. Diagnostic tools unavailable or not authenticated

**Symptoms:** Export-AADCloudSyncToolsLogs required Connect-AADCloudSyncTools; authentication required missing MSAL.PS; a fresh shell did not recognize the commands.

**Action:** Import the bundled module in the same elevated Windows PowerShell session, install the official prerequisites, authenticate, then collect verbose logs.

```powershell
Import-Module "C:\Program Files\Microsoft Azure AD Connect Provisioning Agent\Utility\AADCloudSyncTools" -ErrorAction Stop
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-AADCloudSyncToolsPrerequisites
Connect-AADCloudSyncTools
Export-AADCloudSyncToolsLogs -TracingDurationMins 3
```

**Verification:** Diagnostic ZIP was produced and analyzed. Collection began when the console displayed Capturing ... verbose log. The service-stop warnings preceded capture.

## 4. ADSync module not found by short name

**Symptom:** Import-Module ADSync failed, although the ADSync service was Running. Scheduler commands were consequently unavailable.

**Action:** Import the installed module by full path in elevated Windows PowerShell:

```powershell
Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1" -ErrorAction Stop
```

**Verification:** Scheduler output showed SyncCycleEnabled False, StagingModeEnabled False, and SyncCycleInProgress False before the pilot run.

## 5. Synced pilot could not sign in

**Evidence:** Emma existed in Entra with on-premises sync enabled. AD showed Enabled True, LockedOut False, and pwdLastSet 0.

**Action:** Cleared ChangePasswordAtLogon for Emma only and reset her AD password using secure input. Waited for password synchronization and retried cloud authentication.

**Outcome:** The owner reported successful sign-in. This is consistent with temporary-password handling in Password Hash Synchronization. No exact original sign-in error code was captured, so the conclusion is limited to the observed state/action/outcome.

**Limit:** This adjustment was not applied to all 70 users. Ordinary object sync and password hash sync are separate processes; repeated Initial cycles are not a password-sync fix.

## 6. Existing Intune client lacked usable administrator credentials

**Evidence:** Win11-Intune showed AzureAdJoined YES / DomainJoined NO. An enabled local account, Lab User, was in Administrators, but its password was unknown. The old AlexKim cloud identity remained listed locally after the cloud user had been deleted. No LAPS password was available.

**Action:** Preserved the original device and chose a separate AD client rather than disconnecting Entra or attempting an offline password bypass.

**Current blocker:** The replacement win-lab installation used an image the owner later identified as wrong and included an Emma sign-in during setup. Its join state was not rechecked. Reinstallation with verified media and a known local administrator is pending.

**Lesson:** WORKGROUP does not rule out Entra join. Inspect dsregcmd state before changing device identity, and establish a recoverable local administrator before onboarding.

## 7. File permissions configured, functional access untested

Supplied command output confirms four department SMB shares and intended NTFS entries. No successful employee file operations or denied cross-department access were observed because client preparation was blocked.

Do not treat ACL listing, Access-Based Enumeration, or a hidden share name as evidence of an end-to-end authorization test. Verify the actual user, group token, server name, SMB credentials, and both share/NTFS permissions from a client.

## References

- [Cloud Sync troubleshooting](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-troubleshoot)
- [On-demand input format](https://learn.microsoft.com/en-us/entra/identity/hybrid/on-demand-provision)
- [AADCloudSyncTools](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/reference-powershell)
- [Password hash sync troubleshooting](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/tshoot-connect-password-hash-synchronization)
- [Device join-state interpretation](https://learn.microsoft.com/en-us/entra/identity/devices/troubleshoot-device-dsregcmd)
