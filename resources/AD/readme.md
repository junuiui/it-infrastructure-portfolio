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

Emma Wilson is retained but disabled in AD and Entra. The newly uploaded ADUC image places her in HR/Users. Supplied properties show GG_HR_Users removed, leaving Domain Users; Microsoft 365 shows Sign-in blocked and Licenses (0). Session revocation was instructed but its execution was not explicitly evidenced. Data disposition is not inferred from the absence of a current license.

ADUC Saved Queries confirmed 71 department-filtered employee objects, 70 enabled and one disabled (Emma). These are owner-confirmed query counts. No final CSV export has been committed. The original baseline CSV still contains 70 entries and includes Emma.

## Script reuse notes

- The creation script defaults UPN suffix to AD DNSRoot unless explicitly supplied. For a new hybrid deployment, supply the configured tenant suffix.
- It sets ChangePasswordAtLogon true. Pilot/cloud password handling was changed separately; do not assume every original user can sign in to the cloud with the initial password.
- It skips existing accounts and does not reconcile UPNs, titles, enabled states, or membership.
- Before reuse, extract $ou.DN into a scalar variable for the OU filter, as shown in the main How-to.
- health-check.ps1 counts department Users OUs without filtering Enabled. Emma was previously outside those child OUs, but the new screenshot shows her under HR/Users. The script is a baseline helper, not a reconciled live inventory.
- Department/OU changes do not automatically move group access. The mover test updated memberships explicitly.
- Existing users may retain group membership while disabled; object count, enabled count, and effective access are separate.
- Passwords are not stored in the CSV/docs.

## Verified lifecycle

| Scenario | Identity | Result |
|---|---|---|
| Joiner | Jamie Morgan | AD/group access → Entra sync → cloud login → Outlook → Intune primary-user association |
| Mover | Engineering test employee, name not captured | HR transfer and permission change tested; owner restored original state |
| Leaver | Emma Wilson | Disabled; HR access group removed; zero current M365 licenses; session/data completion not claimed |

See [How-to Guide](../../HowTo.md) for GUI instructions and focused verification commands.

## Saved Query inventory

In ADUC, use Saved Queries → New Query → Define Query → Custom Search → Advanced. Search the integration domain, including subtree OUs.

All employee objects:
```text
(&(objectCategory=person)(objectClass=user)(|(department=HR)(department=Engineering)(department=Sales-Marketing)(department=IT)))
```

Enabled employees:
```text
(&(objectCategory=person)(objectClass=user)(|(department=HR)(department=Engineering)(department=Sales-Marketing)(department=IT))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
```

Disabled employees:
```text
(&(objectCategory=person)(objectClass=user)(|(department=HR)(department=Engineering)(department=Sales-Marketing)(department=IT))(userAccountControl:1.2.840.113556.1.4.803:=2))
```

Verified results: 71 / 70 / 1. Export through Export List when preserving the inventory. These queries select people by Department, so they exclude nonemployee objects without a matching department; they are not domain-wide account counts.

## Temporary read-only test

Actual Global group: GG-HR-ReadOnly_Test. Intended chain:
```text
Nolan Allen -> GG-HR-ReadOnly_Test -> DL_HR_Share_Read -> HR share Read/RX
```

Nolan retained GG_IT_Users. The client temporarily used the IT computer OU while remaining on HR VMnet4. Screenshots show Nolan's read success and denied save/create/delete. Cleanup/revoked HR access and return to HR/Computers with Jamie were owner-reported; a final direct-membership export was not supplied.
