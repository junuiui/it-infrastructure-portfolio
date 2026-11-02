# Problem-solving

[README](README.md) · [How-to](HowTo.md) · [Evidence index](resources/photos/readme.md)

This document records the symptom, evidence, reason for each approach, change, and verification. Use the How-to for the final build sequence. A workaround is not a confirmed root cause.

## 1. DC DNS failed after switching to bridged networking

**Problem:** dcdiag could not resolve the DC GUID under _msdcs.jh.test. It reported no LDAP connectivity, invalid DNS servers, and missing DC records.

**Evidence:** The DC had a dynamic address and used home-network DNS servers 192.168.1.254 and 75.153.176.9.

**Approach and reason:** Check the DC's address and DNS before changing provisioning. AD locator records must resolve through AD DNS; ordinary Internet access does not establish that.

**Change:** Put the DC on isolated VMnet3 at 192.168.1.2/28, gateway 192.168.1.1, NIC DNS 192.168.1.2. Configure public resolvers as DNS forwarders and register the DC's DNS records.

**Verification:** Gateway ping and outbound TCP 443 passed. DNS passed by session report; later client SRV lookups returned the DC at 192.168.1.2.

**Boundary:** DNS repair did not resolve the separate Cloud Sync timeout. The complete original dcdiag transcript is not archived here.

## 2. Cloud Sync timed out — Connect Sync used instead

**Problem:** On-demand provisioning for the pilot user timed out. Portal provisioning logs stayed empty. Agent Running / Active did not demonstrate successful provisioning.

**Pilot:** CN=Emma Wilson,OU=Entra-Pilot,DC=jh,DC=test. Observed agent version: 1.1.2507.0. The Cloud Sync configuration was disabled while on-demand testing was used.

| Approach | Why it was used | Result |
|---|---|---|
| Correct the on-demand identifier | Match the documented Distinguished Name input | Initial ObjectGUID guidance was corrected; timeout remained |
| Repair AD DNS | Eliminate the known DC locator failure | DNS passed; timeout remained |
| Test TCP 443 and actual cloud endpoints | Separate basic reachability/TLS from provisioning | An endpoint returned an HTTP response without bypassing certificate checks; authenticated WebSocket operation was not established |
| Inspect WinHTTP proxy | Check the machine proxy path | Direct access reported; this did not exclude every intermediary |
| Restart and collect verbose traces | Find whether requests reached the agent and where processing stopped | Relay request and ACK observed; follow-up WebSocket connection failed |
| Create the missing Endpoints folder | Address a recorded local write/permission issue | Inherited gMSA access and endpoints.txt creation confirmed; timeout remained |
| Reinstall/register the agent | Test whether installation/registration state explained the failure | Same timeout reported |
| Test Connect Sync | Meet the identity objective through another supported sync path | Pilot, workforce synchronization, cloud sign-in and attribute update succeeded |

The decisive trace sequence was:

```text
Client request received via Relay
Returning Ack
Establishing web socket connection (Timeout: 30000 ms)
Web socket failed to connect
```

Other traces included forced closure and ServiceBusClientWebSocket EOF. These show that a request reached the agent; they do not identify the failed intermediary or endpoint.

Local errors also mentioned pap_connector_lib.dll during event logger initialization, performance counters, and Endpoints access. Fixing the folder did not fix provisioning. The DLL message was not proven to cause the WebSocket timeout.

**Resolution for the project:** Disable Cloud Sync and stop its agent; use Connect Sync. Do not run both engines against overlapping users.

**Unresolved:** The original timeout and empty portal logs. Double NAT, TLS inspection, gMSA binding and tenant-side failure were hypotheses, not findings. The timeout existed before the Ubuntu double-NAT setup. An HTTPS HEAD response is not a WebSocket test; an encrypted packet capture cannot directly show HTTP/WebSocket payloads without decryption.

## 3. Cloud Sync diagnostic commands were unavailable

**Problem:** Log export required authentication; authentication required MSAL.PS. A new shell did not recognize the commands.

**Approach and reason:** Load the agent's bundled utility in the same elevated PowerShell session. Use its prerequisite installer rather than assume the module is globally available.

**Change:**

```powershell
Import-Module "C:\Program Files\Microsoft Azure AD Connect Provisioning Agent\Utility\AADCloudSyncTools" -ErrorAction Stop
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-AADCloudSyncToolsPrerequisites
Connect-AADCloudSyncTools
Export-AADCloudSyncToolsLogs -TracingDurationMins 3
```

**Verification:** A diagnostic archive was produced. The capture interval began at the Capturing verbose log message, after the service-stop warnings.

This is the historical investigation procedure, not a requirement for the working Connect Sync build.

## 4. ADSync service was running, but its module was not found

**Problem:** Import-Module ADSync failed, so scheduler commands were unavailable.

**Approach and reason:** Distinguish a running service from PowerShell module discovery.

**Change:** Import the installed module directly:

```powershell
Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1" -ErrorAction Stop
```

**Verification:** Scheduler commands worked. During pilot preparation the scheduler was disabled and staging mode was off. It was later enabled after workforce verification.

## 5. A synchronized pilot could not sign in

**Problem:** Emma existed in Entra, but initial cloud sign-in failed.

**Evidence:** AD Enabled True, LockedOut False, pwdLastSet 0.

**Approach and reason:** Check account/password state separately from object synchronization. A visible Entra object does not prove the password is ready for cloud authentication.

**Change:** For this pilot only, clear ChangePasswordAtLogon and reset the AD password using secure input. Allow Password Hash Synchronization to process and retry.

**Verification:** Cloud sign-in succeeded by session report; the subsequent AD job-title update appeared in Entra.

**Boundary:** No original sign-in error code was retained. The observed state and recovery are consistent with temporary-password handling, not proof of every possible cause. No blanket reset of all employees was performed.

## 6. The old client had no usable administrator credentials

**Problem:** The earlier Intune VM was Entra joined, not AD joined. Its local administrator password was unknown, and a removed cloud user remained listed as an administrator.

**Approach and reason:** Preserve that project and build a separate client with a known administrative recovery path.

**Change:** Install Windows 11 Pro, create local LabAdmin, join jh.test, and use HR-PC-01 for integration.

**Verification:** Local administrator elevation and domain access worked.

**Related sign-in issue:** A bare LabAdmin name was interpreted in domain JH. Explicit HR-PC-01\\LabAdmin or .\\LabAdmin selected the local account.

**Boundary:** Administrator recovery on the original VM was not completed.

## 7. File ACL configuration did not prove effective access

**Problem:** Initial output listed correct SMB/NTFS permissions, but configuration alone did not demonstrate employee access.

**Approach and reason:** Test actual operations as ordinary users. A hidden share, ABE, or group name is not an access-control test.

**Change:** Reuse the client sequentially with Ava Collins/HR, Luke Fisher/ENG, Nora Green/SM and Nolan Allen/IT. Test own-share file operations and unauthorized department shares.

**Verification:** Department operations and tested cross-department denials passed by session report. Saved images show representative resource access/denial.

**Boundary:** This proves identity-based share authorization, not network packet isolation. All shares are on the same DC/IP, so network ACLs cannot distinguish HR$ from ENG$ by share name.

A user's OU did not grant access: Emma could access HR while still in Entra-Pilot because she belonged to GG_HR_Users. Workstation logon policies followed the computer OU.

## 8. Netplan accepted placeholder names, but Relay failed

**Problem:** New interfaces stayed unconfigured; isc-dhcp-relay exited with status 1 even though Netplan accepted the YAML.

**Evidence:** The file still contained ENG_NIC, SM_NIC and IT_NIC placeholders.

**Approach and reason:** Match VMware adapter MAC addresses to real Linux device names. Valid YAML does not prove a NIC exists.

**Change:**

| VMware network | MAC suffix | Linux NIC | Gateway |
|---|---|---|---|
| VMnet5 / ENG | :98 | ens39 | 192.168.0.1/26 |
| VMnet6 / SM | :a2 | ens40 | 192.168.1.65/26 |
| VMnet7 / IT | :ac | ens41 | 192.168.1.17/28 |

Update both Netplan and Relay, apply, and restart Relay.

**Verification:** Relay became active. Department DHCP/connectivity tests passed; later restart screenshots showed all six router NICs, one default route, five NAT rules and active Relay.

## 9. Compliance overview and policy details disagreed

**Problem:** The device overview showed Compliant, while the default-policy row showed Has a compliance policy assigned / 65001 (Not applicable).

**Approach and reason:** Inspect the assigned policy and per-setting result instead of treating an overview badge as proof. The existing WIN-COMP-Sales-Bitlocker policy was not an HR assignment.

**Change:** Create WIN-COMP-HR-Pilot, requiring Firewall, Antivirus and Real-time protection, and assign it to SG-Intune-Pilot-Users.

**Verification:** The owner reported Compliant for the HR policy.

**Boundary:** The exact cause/final status of the earlier default row was not captured. The HR policy did not require BitLocker; its result was not evidence of encryption.

## 10. The login banner appeared before its report updated

**Problem:** Windows displayed the new banner while the Intune profile report showed all zero counts.

**Approach and reason:** Compare the actual client result with the report before recreating a working policy.

**Change:** Keep IN-CONFIG-Pilot-LogonBanner and allow reporting to update.

**Verification:** The saved portal image later showed Succeeded 1, Error 0, Conflict 0. Both client display and policy report were captured.

**Boundary:** A demonstrated reporting delay for this banner does not explain every later policy-delivery problem.

## 11. Console syntax errors looked like verification failures

**Problem:** PowerShell commands were entered in CMD with copied prompts/output. Later, cc# was pasted before a PowerShell comment.

**Approach and reason:** Separate shell/input errors from service failures.

**Change:** Open the correct PowerShell shell and copy only the command body.

**Verification:** Network tests ran successfully. In the cc# case, the next registry command still executed; its output remained valid.

## 12. The temporary HR Read test used the wrong membership path

**Problem:** Nolan had the test Global group but could not open HR data. During troubleshooting the resource DL was added directly to the user.

**Approach and reason:** Inspect the group chain rather than broaden the share ACL.

**Change:**

```text
Nolan → GG-HR-ReadOnly_Test → DL_HR_Share_Read → SMB Read / NTFS RX
```

Remove the direct DL grant. Add the Global group through the DL group's **Members** tab. Sign out/in to renew Nolan's token.

**Verification:** Named-user images showed read allowed and original-path save, create and delete denied. A local Save As copy is not a write to the protected share.

**Cleanup:** Temporary access removal and return to HR/Computers with Jamie were reported successful. A final nested-membership export was not saved.

## 13. The employee LDAP filter had mismatched parentheses

**Problem:** The enabled/disabled filter closed the outer AND expression too early.

**Approach and reason:** Keep the department OR expression and account-state test inside the same AND.

**Change:** Use the corrected Saved Query filters in How-to section 17.

**Verification:** The owner confirmed 71 employee objects, 70 enabled and one disabled. These are live AD department counts, not total tenant objects or the original CSV count.

## 14. Windows LAPS commands were missing on the DC

**Problem:** Update-LapsADSchema and Set-LapsADComputerSelfPermission were not recognized.

**Evidence:** jh.test was at Windows2016Domain functional level; command availability, not domain level, was the first blocker.

**Approach and reason:** Check Get-Module -ListAvailable LAPS and the standard module path before changing AD. Windows LAPS is delivered through Windows updates.

**Change:** Update Windows Server 2022, then import LAPS.

**Verification:** The module and both commands became available. Schema preparation and the scoped GPO proceeded.

## 15. LabAdmin's old password stopped working; AD lookup also failed

**Problem:** UAC rejected the old LabAdmin password. Get-LapsADPassword then returned supplied credential is invalid.

**Evidence:** hostname / whoami showed HR-PC-01 and hr-pc-01\\labadmin. Later event 10018 explicitly confirmed the new password was stored in AD.

**Approach and reason:** Separate local administrator identity from domain identity, and verify whether LAPS had already rotated the password. Local elevation does not grant LDAP authentication as a domain administrator.

**Change:** Query LAPS on the DC as JH\\Administrator. Retrieve the current password privately and use it for HR-PC-01\\LabAdmin elevation.

**Verification:** The owner successfully used the managed credentials. Reset-LapsPassword advanced the stored update time; DecryptionStatus was Success, with a 30-day expiry.

**Conclusion:** Background LAPS processing explained the changed local credential state. The LDAP error occurred under a local account; it was not proof that AD password storage failed.

No managed password is included in repository evidence.

## 16. BitLocker silent encryption failed — resolved with split policy ownership

### A. Installation media blocked encryption

**Problem:** The event began Failed to enable Silent Encryption / TPM is not available, but its detailed error said bootable CD/DVD media was detected.

**Evidence:** TPM reported ready and WinRE was enabled. C: was Fully Decrypted, 0%, no protectors.

**Approach and reason:** Follow the specific error detail rather than clear or replace a ready TPM.

**Change:** Disconnect the Windows ISO in VMware CD/DVD settings, clear Connect at power on, and restart Windows.

**Verification:** The next failure changed to recovery-policy backup. Media removal cleared that observed blocker.

### B. AD recovery backup was not allowed

**Problem:** Event 851 reported that Group Policy prevented recovery-password backup to AD. Warning 778 said the volume reverted to an unprotected state.

**Evidence:**

```text
OSActiveDirectoryBackup        = 0
OSRequireActiveDirectoryBackup = 0
OSRecoveryPassword             = 2
```

The initial guidance had disabled AD DS backup to target Entra storage. That was the wrong configuration for the chosen hybrid recovery workflow.

**Approach and reason:** Inspect actual client policy values rather than infer them from an Intune Properties page.

**Attempt:** Change Intune OS recovery settings to permit/require AD backup. The portal showed the new values, but the client retained the old values. The latest matching event 814 still contained the original false flags.

### C. Corrected Intune recovery settings did not appear on the client

**Attempts and observations:**

| Approach | Reason | Observation |
|---|---|---|
| Local and remote Sync; restart | Give the changed policy a processing opportunity | No verified corrected recovery payload |
| RSoP | Check whether a domain BitLocker GPO was overriding MDM | No BitLocker GPO shown at that stage; RSoP does not report Intune policy |
| Remove/reapply the recovery setting | Try a fresh delivery of that setting | FVE policy path disappeared; it did not return with corrected values |
| Separate IN-ENC-HR-Recovery profile | Test recovery delivery separately from encryption settings | Assignment report remained Pending; corrected client recovery setting was still absent |
| Inspect client management state and logs | Distinguish transport/reporting from actual setting application | Local sync reported success, while portal check-in/reporting did not establish delivery |
| Inspect PolicyManager | Check settings held by MDM | RequireDeviceEncryption 1, warning 0, standard-user encryption 1; SystemDrivesRecoveryOptions empty |

A blank selected property does not independently prove every MDM processing detail. Combined with missing FVE policy values and no corrected recovery event, it showed that recovery-policy application had not been established. Repeated Sync and waiting did not supply new evidence.

**Working change:** Remove the standalone recovery profile's device-group assignment. Leave recovery options Not configured in IN-ENC-HR-BitLocker. Keep its three encryption settings. Create **GPO-HR-BitLocker-Recovery**, linked to HR/Computers, and require a recovery password plus AD backup before enablement.

**Verification:**

1. gpupdate applied recovery values **1 / 1 / 1**.
2. Intune management Sync was triggered with the encryption requirement still present.
3. C: progressed through 95.3% to **Fully Encrypted, 100%, Protection On**.
4. Algorithm: **XTS-AES 128**; protectors: TPM and Numerical Password.
5. An AD msFVE-RecoveryInformation child record was returned; the owner confirmed a key in the Intune/Entra view.

**Conclusion:** The working combination is **Intune encryption requirement + AD GPO recovery settings**. Intune was not fully replaced.

**Unresolved:** Why the revised Intune recovery setting did not reach/apply to this client. This is not proof of a universal Intune limitation or a confirmed service defect. The final policy split is a workaround. No forced recovery boot or BitLocker noncompliance/Conditional Access test was performed.

## References

- [Cloud Sync troubleshooting](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-troubleshoot)
- [On-demand provisioning input](https://learn.microsoft.com/en-us/entra/identity/hybrid/on-demand-provision)
- [AADCloudSyncTools](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/reference-powershell)
- [Password Hash Synchronization](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/tshoot-connect-password-hash-synchronization)
- [Device join-state interpretation](https://learn.microsoft.com/en-us/entra/identity/devices/troubleshoot-device-dsregcmd)
- [Netplan examples](https://netplan.readthedocs.io/en/stable/examples/)
- [Windows LAPS with AD](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory)
- [Windows LAPS supported platforms](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [Intune BitLocker](https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/encrypt-bitlocker-windows)
- [BitLocker CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/bitlocker-csp)
- [BitLocker client troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-protection/troubleshoot-bitlocker-policies)
