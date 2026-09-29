# Gmail configuration
$gmail = "YOUR_TEST_GMAIL@gmail.com"

$password = Read-Host "Enter Gmail App Password" -AsSecureString

$credential = New-Object System.Management.Automation.PSCredential(
    $gmail,
    $password
)

# Find all d007 service accounts
$accounts = Get-ADUser -Filter 'SamAccountName -like "d007*"' `
    -Properties Enabled,PasswordExpired,Description

foreach ($account in $accounts) {

    # Check password status
    if ($account.PasswordExpired) {

        # Extract owner from Description
        $ownerName = $account.Description -replace "Owner:", ""

        # Find owner in AD
        $owner = Get-ADUser -Filter "SamAccountName -eq '$ownerName'" `
            -Properties mail

        if ($owner -and $owner.Enabled -and $owner.mail) {

            $subject = "Service Account Password Expired - $($account.SamAccountName)"

            $body = @"
Hello $($owner.Name),

The following service account requires attention.

Service Account : $($account.SamAccountName)
Status          : Password Expired
Owner           : $($owner.Name)

Please take the required action.

This is an automated notification from the AD automation lab.
"@

            Send-MailMessage `
                -From $gmail `
                -To $owner.mail `
                -Subject $subject `
                -Body $body `
                -SmtpServer "smtp.gmail.com" `
                -Port 587 `
                -UseSsl `
                -Credential $credential

            Write-Host "EMAIL SENT → $($owner.mail)"
        }
        else {

            Write-Host "WARNING: Owner information is invalid for $($account.SamAccountName)"
        }
    }
}
