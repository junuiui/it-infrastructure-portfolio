# Problems and Resolutions

[README](README.md) · [How-to Guide](HowTo.md) · [Session Record](progress-2026-10-30.md)

Updated through October 31, 2026. This document separates symptoms, evidence, actions, and outcomes. A working recovery sequence is not presented as proof of the original root cause.

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

## 6. Existing Intune client lacked usable administrator credentials — bypassed with a separate client

The earlier Win11-Intune VM was Entra joined, not AD joined. The local administrator password was unknown and a deleted cloud user remained listed as an administrator. The owner reported no available LAPS recovery password.

Preserved that VM. Installed a separate Windows 11 Pro client, created LabAdmin, joined jh.test, and renamed it HR-PC-01. Its initial local-admin sign-in failed when Windows interpreted LabAdmin in domain JH. Explicit HR-PC-01\LabAdmin or .\LabAdmin selected the local account correctly.

The old machine's administrator recovery was not completed. The new client provided a working path for this integration.

## 7. File ACL inspection versus functional authorization — tests completed

October 30 supplied output confirmed SMB/NTFS configuration only. On October 31, standard employees tested department access from the domain client.

Ava Collins (HR), Luke Fisher (ENG), Nora Green (SM), and Nolan Allen (IT) reported successful own-share file operations and the instructed cross-department denials. The same client was moved sequentially between department networks and computer OUs.

File names, a hidden share suffix, Access-Based Enumeration, or an ACL listing alone are not acceptance evidence. A missing network path and a wrong-password message are not successful authorization denials.

Read DL groups were not separately tested. Department group membership does not depend on a user being in that department's OU: Emma initially remained in Entra-Pilot but received HR access through GG_HR_Users. Computer-side logon GPOs followed the computer OU.

## 8. Placeholder interface names left in Netplan and DHCP Relay — resolved

**Symptoms:** Newly added ens39/ens40/ens41 interfaces remained unconfigured, while netplan generate/try accepted the YAML. Relay exited with status 1.

**Evidence:** Saved configuration still used ENG_NIC, SM_NIC, IT_NIC. These were illustrative placeholders, not interface names.

**Action:** Matched VMware network adapter MAC addresses to Ubuntu devices:
- VMnet5 / MAC suffix :98 → ens39 → 192.168.0.1/26.
- VMnet6 / :a2 → ens40 → 192.168.1.65/26.
- VMnet7 / :ac → ens41 → 192.168.1.17/28.

Updated both Netplan and Relay, applied configuration, and restarted Relay.

**Outcome:** Owner confirmed Relay active and all four department functional tests passed.

**Prevention:** Use the concrete verified mapping in the current How-to. Valid YAML does not prove a configured identifier matches a connected NIC. Do not add a default route to each internal interface.

## 9. Hybrid join returned error_missing_device during registration

### Initial deployment

The synced computer first appeared Pending in Entra. Connect Sync processed the in-scope computer, and a later Automatic-Device-Join task completed registration.

### Re-registration during MDM investigation

A diagnostic dsregcmd /leave step reset local Entra registration while preserving AD domain membership. The previously working hybrid join temporarily became AzureAdJoined NO.

The client reported:
```text
Client ErrorCode: 0x801c03f3
Server ErrorSubCode: error_missing_device
Server Operation: DeviceRenew
```

AD ObjectGUID matched the Entra Device ID, the AD computer had one userCertificate value, tenant discovery returned the intended tenant, and the automatic task ran as SYSTEM. Therefore an ID mismatch or wrong tenant was not established.

After sync requests and a fresh task run, event 306 reported Automatic registration Succeeded. Earlier kerb/fallback failure events remained in the same event log and did not negate the later success.

Final owner-supplied output:
```text
DomainJoined: YES
AzureAdJoined: YES
DeviceAuthStatus: SUCCESS
AzureAdPrt: YES
KeySignTest: PASSED
```

**Limit:** Final connector export details were not supplied, so no specific export change is claimed as the single fix. Registration/directory processing timing may have contributed; the exact reason the service temporarily rejected an existing device ID was not proven.

**Recovery boundary:** The leave step temporarily interrupted a working device join. It is a documented incident action, not a default enrollment step. Do not repeatedly run leave, delete portal objects, or unjoin AD as a response to ordinary reporting delays.

## 10. Intune autoenrollment failed with 0x80180031 — recovered

### Observations

- Device was initially hybrid joined and Jamie had a PRT.
- Autoenrollment task existed.
- Effective GPO: AutoEnrollMDM 1, UseAADCredentialType 1; server UI User Credential.
- Jamie was directly in the pilot user group and had the Intune service licensed.
- Tenant MDM authority Microsoft Intune; account Active.
- Only one Mobility provider, Microsoft Intune.
- Configured discovery URL was correct and WIP scope None.
- dsregcmd MDM URLs and cached TenantInfo URL fields were empty.

The current Windows image recorded failures in:
```text
Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Enrollment
```

The Admin channel contained older initialization information. Filtering Admin only for event 76 hid the relevant failures.

Events 76/90 reported MDM not configured and null resource URLs. Their Device Credential (0x0) wording did not override the effective User Credential policy evidence.

### Actions and outcome

1. Verified policy, license, group membership, tenant authority/provider, and URLs.
2. Compared Some versus All MDM scope; URLs initially stayed empty.
3. Re-registered the Entra device using the incident procedure described above.
4. After successful event 306 and Jamie reauthentication, device authentication and PRT were valid and all MDM URLs were populated.
5. Ran the automatic enrollment task.
6. Client Info showed an Intune management server and successful sync.
7. Intune portal subsequently displayed HR-PC-01 with primary user Jamie Morgan.

**Working outcome verified. Original cause unconfirmed.** Changes, synchronization, elapsed processing time, registration refresh, and sign-in happened in sequence; no controlled result isolates one as the sole root cause.

Final owner preference is MDM scope All, WIP None. Compliance and configuration assignments remain pilot scoped.

### Status codes and diagnostics

- 0x80180031: MDM not configured.
- 0x41301 in Task Scheduler: task running, not success.
- 0x41303: task has not yet run.
- Registration event 306: automatic device registration success, not Intune enrollment success.
- Attestation event 3016: attestation success, not proof of MDM inventory presence.
- MDM URLs being populated: discovery information available, not enrollment proof.

Use actual client management state and portal device/check-in evidence for enrollment acceptance.

## 11. Default compliance policy showed 65001 — pilot policy evaluated

The overview badge showed Compliant while the default-policy report showed:
- Has a compliance policy assigned: Error, 65001 (Not applicable).
- Is active: Compliant.
- Enrolled user exists: Compliant.

The only earlier explicit policy was WIN-COMP-Sales-Bitlocker. Created WIN-COMP-HR-Pilot with Firewall, Antivirus and Real-time protection required, assigned to SG-Intune-Pilot-Users.

Owner reported the new policy Compliant. The old Sales policy and tenant-wide no-policy behavior were not weakened to manufacture a green result.

**Limit:** The exact origin of default-policy 65001 and its separate final row status were not captured. Do not equate that row with failed BitLocker/antivirus checks. The new policy result does not establish HR drive encryption.

## 12. Login banner applied before portal report updated — resolved

Created and assigned IN-CONFIG-Pilot-LogonBanner to SG-Intune-Pilot-Devices. Windows displayed the configured title and text, while the portal initially showed all result counts zero.

Later screenshot:
```text
Succeeded: 1
Error: 0
Conflict: 0
Not applicable: 0
In Progress: 0
```

This supports a reporting delay for this profile. The earlier empty MDM URLs and failed enrollment were separate incidents, not explained away by the later portal delay.

## 13. Command Prompt and copied console output confused verification — corrected

PowerShell-only commands were entered in CMD together with copied C:\Users\LabAdmin> prompts/output. Those command errors were not network failures.

Opened PowerShell and copied only the command body. Subsequent owner-reported SMB/HTTPS tests returned True.

## References

- [Cloud Sync troubleshooting](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-troubleshoot)
- [On-demand input format](https://learn.microsoft.com/en-us/entra/identity/hybrid/on-demand-provision)
- [AADCloudSyncTools](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/reference-powershell)
- [Password hash sync troubleshooting](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/tshoot-connect-password-hash-synchronization)
- [Device join-state interpretation](https://learn.microsoft.com/en-us/entra/identity/devices/troubleshoot-device-dsregcmd)

- [Hybrid device registration and diagnostics](https://learn.microsoft.com/en-us/entra/identity/devices/troubleshoot-hybrid-join-windows-current)
- [MDM error definitions](https://learn.microsoft.com/en-us/windows/win32/mdmreg/mdm-registration-constants)
- [MDM enrollment diagnosis](https://learn.microsoft.com/en-us/windows/client-management/mdm-diagnose-enrollment)
- [Compliance policy behavior](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)
- [Netplan static interfaces](https://netplan.readthedocs.io/en/stable/examples/)
