# AD Resources

[How-to Guide](../../HowTo.md) · [Company Specification](../../company-spec.md) · [October 31 Record](../../progress-2026-10-31.md)

| File | Purpose |
|---|---|
| [employees.csv](employees.csv) | Original 70-person synthetic workforce baseline |
| [new-user-script-from-csv.ps1](new-user-script-from-csv.ps1) | Original OU/user provisioning script |
| [health-check.ps1](health-check.ps1) | Original OU-based user count and DC checks |

These files are preserved; this update changes documentation, not provisioning code or baseline CSV data.

## Baseline versus current state

The CSV has FirstName, LastName, Department, PositionName. Baseline staffing is HR 8, Engineering 35, Sales-Marketing 22, IT 5.

Jamie Morgan was created separately through the GUI for the joiner test:
- SamAccountName: jamiemorgan.
- UPN: jamiemorgan@junuihonglab.onmicrosoft.com.
- OU: HR/Users.
- Department: HR; Title: HR Assistant.
- GG_HR_Users; Business Premium; cloud sign-in and Outlook tested.
- Primary user of Intune-managed HR-PC-01.

Emma Wilson was retained but disabled in AD and Entra for the leaver test. Her final group cleanup, session revocation, and data handover are not verified. Entra-Pilot was her last captured OU; a move was discussed but not confirmed.

Expected current employee objects: 71. Expected enabled employees: 70 if no other accounts changed. These are derived counts, not a fresh directory export. The original CSV count remains 70 and includes Emma.

## Script reuse notes

- The creation script defaults UPN suffix to AD DNSRoot unless explicitly supplied. For a new hybrid deployment, supply the configured tenant suffix.
- It sets ChangePasswordAtLogon true. Pilot/cloud password handling was changed separately; do not assume every original user can sign in to the cloud with the initial password.
- It skips existing accounts and does not reconcile UPNs, titles, enabled states, or membership.
- Before reuse, extract $ou.DN into a scalar variable for the OU filter, as shown in the main How-to.
- health-check.ps1 counts only department Users OUs. It does not include Emma while in Entra-Pilot, and it does not filter Enabled.
- Department/OU changes do not automatically move group access. The mover test updated memberships explicitly.
- Existing users may retain group membership while disabled; object count, enabled count, and effective access are separate.
- Passwords are not stored in the CSV/docs.

## Verified lifecycle

| Scenario | Identity | Result |
|---|---|---|
| Joiner | Jamie Morgan | AD/group access → Entra sync → cloud login → Outlook → Intune primary-user association |
| Mover | Engineering test employee, name not captured | HR transfer and permission change tested; owner restored original state |
| Leaver | Emma Wilson | AD/Entra disabled and new sign-ins blocked; full offboarding not claimed |

See [How-to Guide](../../HowTo.md) for GUI instructions and focused verification commands.
