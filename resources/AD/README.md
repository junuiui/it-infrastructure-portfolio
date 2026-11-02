# AD Resources

[How-to](../../how-to.md) · [Company specification](../../docs/company-spec.md) · [Validation](../../docs/validation.md)

| File | Purpose |
|---|---|
| [employees.csv](employees.csv) | Original 70-person synthetic workforce baseline |
| [new-user-script-from-csv.ps1](new-user-script-from-csv.ps1) | Original OU/user provisioning script |
| [health-check.ps1](health-check.ps1) | Basic OU user counts and DC checks |

## Before reusing the scripts

The CSV uses FirstName, LastName, Department and PositionName. It is a baseline, not a live inventory: Jamie was added separately and Emma is retained disabled. See the company specification for current counts and naming.

- Supply the configured tenant UPN suffix for a fresh hybrid build. Otherwise the creation script defaults to the AD DNS suffix.
- Correct the OU filter's hashtable-property use before execution; the How-to shows the scalar-variable replacement.
- The creation script skips existing accounts; it does not reconcile existing attributes or memberships.
- ChangePasswordAtLogon is initially true. Complete the domain password-change workflow before assuming cloud sign-in will work.
- The health check counts all users in department Users OUs without filtering enabled state. It is not a live inventory reconciliation.
- OU/Department changes do not automatically update group membership.
- LAPS and BitLocker recovery credentials do not belong in CSV files or script output committed here.

These original scripts and the baseline CSV are preserved unchanged. Setup, inventory queries, group nesting and security procedures are maintained in the main How-to rather than duplicated here.
