# 🔐 AD Service Account Notification Automation

A small enterprise-style automation prototype built with **Windows Server, Active Directory, PowerShell, and Gmail SMTP**.

The goal of this project is to reduce manual effort and notification noise around **service account password issues**.

Instead of manually checking service accounts and sending reminder emails, the automation queries Active Directory, detects an expired password, identifies the account owner, retrieves the owner's email address, and sends an automated notification.

---

## 🏗️ Architecture

```text
                    Active Directory
                           │
                           ▼
                Find d007 Service Accounts
                           │
                           ▼
                  Check Account Status
                           │
                    Password Expired?
                           │
                    ┌──────┴──────┐
                   YES            NO
                    │              │
                    ▼              ▼
              Read Account       Continue
                 Owner
                    │
                    ▼
              Find Owner in AD
                    │
                    ▼
              Get Owner Email
                    │
                    ▼
              Gmail SMTP
                    │
                    ▼
             📧 Email Notification
```

---

## 🚀 What This Prototype Does

The PowerShell automation:

1. Queries Active Directory.
2. Finds accounts beginning with `d007`.
3. Checks whether the password has expired.
4. Reads the configured account owner.
5. Looks up the owner in Active Directory.
6. Retrieves the owner's email address.
7. Sends an automated notification through Gmail SMTP.
8. Prints the result to the PowerShell console.

Example:

```text
Service Account: d007_nani01
Password Status: EXPIRED
Owner: Ravi Kumar
Email: test@example.com
```

The owner then receives an email similar to:

```text
Subject: Service Account Password Expired - d007_nani01

Hello Ravi Kumar,

The following service account requires attention.

Service Account : d007_nani01
Status          : Password Expired
Owner           : Ravi Kumar

Please take the required action.

This is an automated notification from the AD automation lab.
```

---

## 🧪 Lab Environment

This prototype was built using:

* AWS EC2
* Windows Server
* Active Directory Domain Services (AD DS)
* PowerShell
* Gmail SMTP
* Test Active Directory users

Example lab structure:

```text
corp.lab
│
├── Employees
│   └── Ravi Kumar
│
└── ServiceAccounts
    └── d007_nani01
```

Example ownership mapping:

```text
d007_nani01 → Ravi
```

The ownership information is represented through the AD `Description` attribute for this prototype:

```text
Owner:Ravi
```

> In a production environment, the organization's approved ownership attribute or CMDB/ServiceNow ownership data should be used instead of relying on the Description field.

---

## ⚙️ Prerequisites

You need:

* Windows Server
* Active Directory Domain Services
* PowerShell
* Active Directory PowerShell module
* A Gmail test account
* Gmail 2-Step Verification enabled
* Gmail App Password

The Gmail App Password should **never be committed to GitHub**.

---

## 🔧 Setup

### 1. Create the test service account

Create a test AD service account such as:

```text
d007_nani01
```

### 2. Configure the owner

For the prototype, configure the owner in the account's Description:

```text
Owner:Ravi
```

### 3. Create the owner account

Create an AD user:

```text
Ravi
```

Configure an email address for the user.

For the lab, this can be your test Gmail address.

Example:

```text
Ravi → testaccount@gmail.com
```

### 4. Verify the service account

```powershell
Get-ADUser d007_nani01 -Properties Enabled,PasswordExpired,Description |
Select-Object Name,SamAccountName,Enabled,PasswordExpired,Description
```

---

## 📜 Running the Automation

Run the PowerShell script:

```powershell
.\check-service-accounts.ps1
```

The script will ask for the Gmail App Password.

```text
Enter Gmail App Password:
```

The password is entered securely and is not displayed on screen.

The automation then:

```text
AD Query
   ↓
Find d007 accounts
   ↓
PasswordExpired?
   ↓
Find Owner
   ↓
Find Owner's Email
   ↓
Send Gmail Notification
```

---

## 📧 Gmail SMTP Configuration

The prototype uses:

```text
SMTP Server : smtp.gmail.com
Port        : 587
TLS         : Enabled
Authentication : Gmail App Password
```

The Gmail account is used only as a test notification sender.

### Important

Do **not** store credentials directly in the PowerShell script.

Bad:

```powershell
$password = "my-secret-password"
```

For this initial prototype, the App Password is entered interactively.

Future versions should use a secure secret store such as:

* Windows Credential Manager
* AWS Secrets Manager
* Azure Key Vault
* Enterprise secret-management solution

---

## 🔍 Current Automation Logic

The current prototype essentially performs:

```text
Get all d007 accounts
        ↓
Check PasswordExpired
        ↓
If expired
        ↓
Read Owner from AD
        ↓
Find Owner AD account
        ↓
Check Owner is enabled
        ↓
Get Owner email
        ↓
Send notification
```

If the owner cannot be found or does not have an email address, the automation reports:

```text
WARNING: Owner information is invalid
```

instead of blindly sending an email.

---

## 🧠 Why This Automation?

In a production environment, service-account notifications can create unnecessary operational noise.

A typical manual process might look like:

```text
Account issue
     ↓
ServiceNow ticket
     ↓
Engineer checks account
     ↓
Engineer finds owner
     ↓
Engineer sends email
```

This prototype explores:

```text
Account issue
     ↓
Automation
     ↓
Identify owner
     ↓
Send notification
```

The idea is to make the notification process automatic while keeping the account owner responsible for the actual action.

---

## 🔮 Future Improvements

This repository is intentionally a **prototype**.

Potential next improvements:

### 1. Secure credential storage

Replace interactive Gmail password entry with:

```text
AWS Secrets Manager
        ↓
PowerShell
        ↓
Gmail SMTP
```

### 2. Password expiry window

Instead of only detecting already-expired accounts:

```text
30 days → Informational
14 days → Reminder
7 days  → Warning
1 day   → Urgent
0 days  → Expired
```

### 3. Owner validation

Validate that:

```text
Owner exists
Owner is enabled
Owner has an email
```

If the owner is disabled:

```text
Service Account
       ↓
Owner disabled
       ↓
Ownership validation required
```

### 4. Fallback ownership

Add:

```text
Primary Owner
      ↓
Backup Owner
      ↓
Application Support Group
```

This prevents notifications from disappearing when an employee leaves a team.

### 5. ServiceNow integration

The next major stage would be:

```text
Active Directory
       ↓
PowerShell
       ↓
ServiceNow REST API
       ↓
Create / update ticket
       ↓
Notification
```

### 6. Scheduled execution

Use Windows Task Scheduler:

```text
Daily
  ↓
Run PowerShell
  ↓
Check service accounts
  ↓
Send notifications
```

### 7. Reporting

Generate a service-account health report:

```text
Total d007 Accounts : 100
Expired             : 5
Expiring < 7 days   : 8
Expiring < 30 days  : 17
Disabled            : 3
Missing Owner       : 2
```

---

## 🔐 Security Considerations

This repository is a learning/prototype project.

For production use:

* Never commit passwords or App Passwords.
* Never commit `.env` files containing secrets.
* Use a proper secret-management system.
* Use a dedicated service identity.
* Follow the organization's AD permissions model.
* Use least-privilege access.
* Validate account ownership before sending sensitive notifications.
* Keep audit logs for automated actions.
* Use the organization's approved mail infrastructure instead of personal Gmail.

Add sensitive files to `.gitignore`:

```gitignore
*.env
*.credential
*.secret
credentials.json
secrets.json
```

---

## 📁 Suggested Repository Structure

```text
ad-service-account-notification-automation/
│
├── scripts/
│   └── check-service-accounts.ps1
│
├── docs/
│   └── architecture.md
│
├── .gitignore
└── README.md
```

---

## 🎯 Project Status

**Current status: Prototype working ✅**

Completed:

* [x] Windows Server lab
* [x] Active Directory Domain Services
* [x] Test service account
* [x] Service-account password status detection
* [x] Owner lookup
* [x] Owner email lookup
* [x] Gmail SMTP integration
* [x] Automated email notification

Planned:

* [ ] Secure credential storage
* [ ] Password expiry window detection
* [ ] Owner validation
* [ ] Backup owner / support-group fallback
* [ ] Windows Task Scheduler
* [ ] ServiceNow REST integration
* [ ] Reporting/dashboard

---

## 📌 Disclaimer

This project is a personal learning and proof-of-concept implementation.

It should not be deployed against production Active Directory, email infrastructure, or ServiceNow environments without appropriate security review, permissions, and organizational approval.
