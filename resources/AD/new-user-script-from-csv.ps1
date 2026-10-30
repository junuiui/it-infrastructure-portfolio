[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$csvPath,

    [string]$upnSuffix
)

Import-Module ActiveDirectory -ErrorAction Stop

if (-not (Test-Path -LiteralPath $csvPath -PathType Leaf)) {
    throw "CSV file not found: $csvPath"
}

# Read the current AD domain.
$domain = Get-ADDomain -ErrorAction Stop
$domainDN = $domain.DistinguishedName

if ([string]::IsNullOrWhiteSpace($upnSuffix)) {
    $upnSuffix = $domain.DNSRoot
}

# Validate the selected UPN suffix.
$forest = Get-ADForest -ErrorAction Stop
$validSuffixes = @($forest.Domains) + @($forest.UPNSuffixes)

if ($upnSuffix -notin $validSuffixes) {
    throw "UPN suffix is not configured in this forest: $upnSuffix"
}

# Import and validate the CSV.
$users = @(Import-Csv -LiteralPath $csvPath)

if ($users.Count -eq 0) {
    throw "CSV contains no users."
}

$requiredColumns = @(
    "FirstName",
    "LastName",
    "Department",
    "PositionName"
)

foreach ($column in $requiredColumns) {
    if ($users[0].PSObject.Properties.Name -notcontains $column) {
        throw "Missing CSV column: $column"
    }
}

$departments = @(
    "HR",
    "Engineering",
    "Sales-Marketing",
    "IT"
)

# Create missing department OUs and their Users child OUs.
$departmentPaths = @{}

foreach ($department in $departments) {
    $departmentDN = "OU=$department,$domainDN"
    $usersDN = "OU=Users,$departmentDN"

    foreach ($ou in @(
        @{ Name = $department; Path = $domainDN; DN = $departmentDN }
        @{ Name = "Users"; Path = $departmentDN; DN = $usersDN }
    )) {
        $existingOU = Get-ADOrganizationalUnit `
            -Filter { DistinguishedName -eq $ou.DN } `
            -ErrorAction Stop

        if (-not $existingOU) {
            New-ADOrganizationalUnit `
                -Name $ou.Name `
                -Path $ou.Path `
                -ProtectedFromAccidentalDeletion $true `
                -ErrorAction Stop
        }
    }

    $departmentPaths[$department] = $usersDN
}

# Prompt once for the initial lab password.
$password = Read-Host "Enter initial password for lab users" -AsSecureString

$created = 0
$skipped = 0
$failed = 0

foreach ($row in $users) {
    $firstName = ([string]$row.FirstName).Trim()
    $lastName = ([string]$row.LastName).Trim()
    $department = ([string]$row.Department).Trim()
    $positionName = ([string]$row.PositionName).Trim()

    if (
        [string]::IsNullOrWhiteSpace($firstName) -or
        [string]::IsNullOrWhiteSpace($lastName) -or
        [string]::IsNullOrWhiteSpace($department) -or
        [string]::IsNullOrWhiteSpace($positionName)
    ) {
        Write-Warning "Required value missing. Skipping row."
        $skipped++
        continue
    }

    if ($department -notin $departments) {
        Write-Warning "Unknown department: $department. Skipping."
        $skipped++
        continue
    }

    # Use lowercase first name + last name without a separator.
    $username = "$firstName$lastName".ToLowerInvariant()
    $upn = "$username@$upnSuffix"

    # Keep generated account names compatible with this naming convention.
    if ($username -notmatch '^[a-z]+$' -or $username.Length -gt 20) {
        Write-Warning "Account name requires manual review: $username"
        $skipped++
        continue
    }

    try {
        # Skip conflicting accounts without modifying them.
        $existingUser = Get-ADUser `
            -Filter {
                SamAccountName -eq $username -or
                UserPrincipalName -eq $upn
            } `
            -ErrorAction Stop

        if ($existingUser) {
            Write-Warning "Account name or UPN already exists: $username"
            $skipped++
            continue
        }

        $parameters = @{
            Name                  = "$firstName $lastName"
            DisplayName           = "$firstName $lastName"
            GivenName             = $firstName
            Surname               = $lastName
            SamAccountName        = $username
            UserPrincipalName     = $upn
            Path                  = $departmentPaths[$department]
            AccountPassword       = $password
            Enabled               = $true
            ChangePasswordAtLogon = $true
            Department            = $department
            Title                 = $positionName
            ErrorAction           = "Stop"
        }

        New-ADUser @parameters

        Write-Host "Created: $upn [$department]" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Warning "Failed: $username. $($_.Exception.Message)"
        $failed++
    }
}

Write-Host ""
Write-Host "Created: $created | Skipped: $skipped | Failed: $failed"