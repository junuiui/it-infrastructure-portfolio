# Count users by department within the four department OUs.
$departments = "HR", "Engineering", "Sales-Marketing", "IT"

foreach ($department in $departments) {
    $users = @(Get-ADUser `
        -Filter * `
        -SearchBase "OU=Users,OU=$department,DC=jh,DC=test")

    [pscustomobject]@{
        Department = $department
        UserCount  = $users.Count
    }
}

# Check domain controller and DNS health.
dcdiag /test:Advertising /test:Services /test:DNS