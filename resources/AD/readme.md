# AD Resources

[How-to Guide](../../HowTo.md) · [Company Specification](../../company-spec.md) · [Session Record](../../progress-2026-10-30.md)

| File | Purpose |
|---|---|
| [employees.csv](employees.csv) | Synthetic 70-person workforce: FirstName, LastName, Department, PositionName |
| [new-user-script-from-csv.ps1](new-user-script-from-csv.ps1) | Department/Users OU creation and user provisioning |
| [health-check.ps1](health-check.ps1) | Original OU-based user count and DC health checks |

These existing scripts are preserved in this documentation update. Their presence is not proof that every current command was executed directly from this repository version.

## Current-state notes

- The creation script defaults the UPN suffix to the AD DNS domain if none is supplied. Use the verified tenant suffix explicitly for a fresh hybrid deployment.
- It marks new users ChangePasswordAtLogon = true. Emma's state was changed separately for the PHS sign-in test.
- It skips existing users; rerunning it does not update their UPNs or titles.
- Review the OU lookup before reuse: extract $ou.DN into a scalar variable and use that value in the AD filter, rather than accessing the hashtable property inside the filter.
- health-check.ps1 counts only department Users OUs. Emma now lives in Entra-Pilot, so that count alone excludes her. Use the CSV-scoped verification in the main guide to count the workforce accurately.
- Current group names and share permissions are documented in the main guide.
- No account password is stored in the CSV or documentation.

See [How-to Guide](../../HowTo.md) for the pilot password handling, sync scope, and verification commands.
