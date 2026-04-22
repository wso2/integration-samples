# Fraud Detection System with Microsoft SQL Server CDC

## Description

This integration uses Change Data Capture (CDC) for Microsoft SQL Server to monitor financial transactions in real-time and automatically detect potentially fraudulent activity. When a transaction exceeds $10,000, the system sends an email alert to the security team.

## Architecture Overview

The system monitors a `transactions` table in a Microsoft SQL Server database using Debezium CDC. When new transactions are inserted, the system evaluates the transaction amount and sends fraud alerts via Gmail for suspicious transactions.

<img width="1000" height="auto" alt="image" src="resources/architecture.png" />

**Flow:**
- SQL Server CDC captures new transaction entries
- Fraud detection logic evaluates transaction amount
- Email alerts sent to security team for amounts > $10,000

## Prerequisites

- **WSO2 Integrator: BI** - Install from [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=WSO2.ballerina-integrator)
- **Docker** - For running Microsoft SQL Server
- **Microsoft SQL Server** with CDC enabled
- **Gmail API credentials** (OAuth 2.0)

## Setup Instructions

### Step 1: Set up Microsoft SQL Server Using Docker

Docker provides the easiest way to run SQL Server across different platforms.

**Prerequisites for Docker Setup:**
- Docker installed and running
- Minimum 2GB RAM available for the container

**Note for ARM-based Macs (Apple Silicon - M1, M2, etc):**

You need to enable Rosetta emulation for x86:
- **Docker Desktop**: Go to Settings and select "Use Rosetta for x86/amd64 emulation on Apple Silicon"
- **Rancher Desktop**: Go to Preferences → Virtual Machine → Emulation, select VZ, and enable "Enable Rosetta Support"

**Run SQL Server Container:**

```bash
docker run -d --name sqlserver \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=YourStrong@Passw0rd" \
  -e "MSSQL_PID=Developer" \
  -e "MSSQL_AGENT_ENABLED=true" \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest
```

**Understanding the Docker Command:**
- `-d`: Run container in detached mode (background)
- `--name sqlserver`: Names the container for easy reference
- `-e 'ACCEPT_EULA=Y'`: Accepts the End User License Agreement
- `-e 'SA_PASSWORD=...'`: Sets the password for the sa (System Administrator) account
- `-e 'MSSQL_PID=Developer'`: Specifies Developer Edition (x86/x64 only)
- `-e 'MSSQL_AGENT_ENABLED=true'`: Enables SQL Server Agent (required for CDC)
- `-p 1433:1433`: Maps port 1433 from container to host

**Verify SQL Server is Running:**

```bash
# Check if container is running
docker ps

# View SQL Server logs
docker logs sqlserver

# Look for this message in logs:
# "SQL Server is now ready for client connections"
```

**Accessing SQL Server:**

Once running, you can connect to SQL Server using:
- **Server**: `localhost,1433` or `localhost`
- **Username**: `sa`
- **Password**: The password you set in the Docker command
- **Authentication**: SQL Server Authentication

### Step 2: Enable CDC on SQL Server Database

Now that SQL Server is running, you need to create the database, table, and enable Change Data Capture.

#### Connect to SQL Server

Choose one of these tools to connect to your SQL Server instance:

**Option A: Azure Data Studio (Recommended - Cross-platform)**

1. Download from https://aka.ms/azuredatastudio
2. Install and open Azure Data Studio
3. Click "New Connection"
4. Enter connection details:
   - Server: `localhost,1433`
   - Authentication type: SQL Login
   - User name: `sa`
   - Password: Your SA password
   - Trust server certificate: ✓ (checked)
5. Click "Connect"

**Option B: sqlcmd (Command-line)**

```bash
# If running via Docker
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C
```

**Option C: VS Code with SQL Server Extension**

1. Install the "SQL Server (mssql)" extension in VS Code
2. Use Command Palette (Cmd/Ctrl+Shift+P) → "MS SQL: Connect"
3. Enter connection details

#### Execute CDC Setup Scripts

Once connected, execute the following SQL commands to set up the database and enable CDC:

```sql
-- ============================================
-- STEP 1: Create the database
-- ============================================
CREATE DATABASE finance_db;
GO

USE finance_db;
GO

-- ============================================
-- STEP 2: Create the transactions table
-- ============================================
CREATE TABLE dbo.transactions (
    tx_id NVARCHAR(50) PRIMARY KEY,
    user_id NVARCHAR(50) NOT NULL,
    amount FLOAT NOT NULL,
    status NVARCHAR(20) NOT NULL,
    created_at BIGINT NOT NULL
);
GO

-- ============================================
-- STEP 3: Enable CDC on the database
-- ============================================
-- This creates the CDC schema and enables CDC infrastructure
EXEC sys.sp_cdc_enable_db;
GO

-- ============================================
-- STEP 4: Verify CDC is enabled on database
-- ============================================
SELECT
    name,
    is_cdc_enabled,
    CASE
        WHEN is_cdc_enabled = 1 THEN 'CDC is enabled'
        ELSE 'CDC is not enabled'
    END AS cdc_status
FROM sys.databases
WHERE name = 'finance_db';
-- Expected result: is_cdc_enabled = 1
GO

-- ============================================
-- STEP 5: Enable CDC on the transactions table
-- ============================================
-- This creates change tracking tables for the transactions table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'transactions',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

-- ============================================
-- STEP 6: Verify CDC is enabled on the table
-- ============================================
SELECT
    name,
    is_tracked_by_cdc,
    CASE
        WHEN is_tracked_by_cdc = 1 THEN '✓ CDC is tracking this table'
        ELSE '✗ CDC is not tracking this table'
    END AS tracking_status
FROM sys.tables
WHERE name = 'transactions';
-- Expected result: is_tracked_by_cdc = 1
GO

-- ============================================
-- STEP 7: View CDC change tables
-- ============================================
-- This shows the change table created by CDC
SELECT * FROM cdc.change_tables;
-- You should see: dbo_transactions
GO

-- ============================================
-- STEP 8: Verify SQL Server Agent is Running
-- ============================================
-- CDC uses SQL Server Agent jobs to capture changes
SELECT
    servicename,
    status_desc
FROM sys.dm_server_services
WHERE servicename LIKE '%Agent%';
-- Expected: status_desc should be 'Running'
GO

-- Alternative verification
EXEC master.dbo.xp_servicecontrol N'QueryState', N'SQLServerAGENT';
-- Expected: Should return 'Running.'
GO

-- ============================================
-- STEP 9: View CDC capture jobs
-- ============================================
EXEC sys.sp_cdc_help_jobs;
-- You should see capture and cleanup jobs listed
GO

-- Check job status in msdb
SELECT
    j.name,
    j.enabled,
    j.date_created
FROM msdb.dbo.sysjobs j
WHERE j.name LIKE 'cdc.finance_db%'
ORDER BY j.name;
-- Expected: enabled = 1 for both jobs
GO
```

### Step 3: Generate Credentials for Sending Emails

To send fraud alert emails, you need to set up Gmail API access using OAuth 2.0.

#### Create a Google Cloud Project

1. Navigate to the [Google Cloud Console](https://console.cloud.google.com)
2. Sign in with your Google account
3. Click on the project dropdown at the top (says "Select a project")
4. Click the "New Project" button
5. Enter project details:
   - Project name: `MSSQL CDC Fraud Detection` (or your preferred name)
   - Organization: Leave default (or select if you have one)
6. Click "Create"
7. Wait for the project to be created (takes a few seconds)
8. Select the newly created project from the project dropdown

#### Enable Gmail API

1. In the Google Cloud Console, ensure your project is selected
2. Navigate to "APIs & Services" → "Library" (from the left sidebar)
3. In the search bar, type "Gmail API"
4. Click on "Gmail API" from the search results
5. Click the "Enable" button
6. Wait for the API to be enabled

#### Configure OAuth Consent Screen

Before creating credentials, you must configure the OAuth consent screen.

1. Navigate to "APIs & Services" → "OAuth consent screen"
2. Click on "Get Started"

**App Information:**

3. Fill in the required fields:
   - App name: `MSSQL CDC Fraud Detector`
   - User support email: Select your email from the dropdown
   - Audience: External
   - Contact Information: Type in your email address
   - Check "I agree to the Google API Services: User Data Policy"
4. Click "Create"

**Scopes:**

5. On the "Data Access" page, click "Add or Remove Scopes"
6. In the filter box, search for `gmail.send`
7. Select the checkbox for:
   - `https://www.googleapis.com/auth/gmail.send` - Send email on your behalf
8. Click "Update" at the bottom
9. Click "Save"

**Test Users:**

10. On the "Audience" page, click "+ Add Users"
11. Enter the Gmail address you'll use to send fraud alerts (your email)
12. Click "Save"

Your OAuth consent screen is now configured!

#### Create OAuth 2.0 Credentials

1. Navigate to "APIs & Services" → "Credentials"
2. Click "+ Create Credentials" at the top
3. Select "OAuth client ID"
4. Configure the OAuth client:
   - Application type: Select "Web Application" from the dropdown
   - Name: `MSSQL CDC Web Client` (or your preferred name)
   - Authorized redirect URIs: `https://developers.google.com/oauthplayground`
5. Click "Create"
6. A pop-up appears with your credentials:
   - **Client ID**: Copy this and save it securely
   - **Client Secret**: Copy this and save it securely
7. Click "Download JSON" to download the credentials file (optional but recommended for backup)
8. Click "OK" to close the pop-up

**Note:** Store these credentials securely. You'll need them in the next step.

#### Generate Refresh Token

The refresh token is a long-lived token that allows your application to send emails without repeated authorization.

**Using OAuth 2.0 Playground:**

1. Navigate to [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground)
2. **Configure OAuth Client:**
   - Click the Settings icon (⚙️) in the top-right corner
   - Check the box for "Use your own OAuth credentials"
   - Enter your credentials from the previous step:
     - OAuth Client ID: Paste your Client ID
     - OAuth Client secret: Paste your Client Secret
   - Close the settings
3. **Select API Scope:**
   - In the left panel under "Step 1: Select & authorize APIs"
   - Scroll down or search for "Gmail API v1"
   - Expand it and select:
     - ☑ `https://www.googleapis.com/auth/gmail.send`
4. **Authorize APIs:**
   - Click the blue "Authorize APIs" button at the bottom
   - You'll be redirected to Google sign-in
   - Select the Google account you added as a test user
   - You may see a warning "This app isn't verified" - click "Continue" → "Continue"
   - Review the permissions and click "Allow"
5. **Exchange Authorization Code:**
   - You'll be redirected back to the Playground
   - The page now shows "Step 2: Exchange authorization code for tokens"
   - Click the blue "Exchange authorization code for tokens" button
6. **Copy Refresh Token:**
   - In the response, you'll see:
     - `access_token`: (Short-lived, expires in 1 hour)
     - `refresh_token`: **This is what you need!**
   - Copy the `refresh_token` value and save it securely

You now have all the credentials needed for Gmail integration!

## Running the Fraud Detection System

### Step 1: Open the Integration Project

1. Open VS Code with WSO2 Integrator: BI installed
2. Click on the BI icon on the sidebar
3. Open the `frauddetectionsystem` project

### Step 2: Configure Variables

1. Open the **Configurations** section from the left panel
2. Add values to all configurable fields:

| Field | Value |
|-------|-------|
| `mssqlHost` | `localhost` |
| `mssqlPort` | `1433` |
| `mssqlUsername` | `sa` |
| `mssqlPassword` | `YourStrong@Passw0rd` |
| `mssqlDatabase` | `finance_db` |
| `mssqlTxTable` | `finance_db.dbo.transactions` |
| `gmailRefreshToken` | (Your refresh token from Step 3) |
| `gmailClientId` | (Your client ID from Step 3) |
| `gmailClientSecret` | (Your client secret from Step 3) |
| `mailRecipient` | (Security email address) |

### Step 3: Run the Integration

1. Click the **▶️ Run** button in the BI extension
2. Wait for the integration to start (you'll see logs in the output panel)

### Step 4: Test the Fraud Detection

Insert a fraudulent transaction into the database:

```sql
USE finance_db;
GO

INSERT INTO dbo.transactions (tx_id, user_id, amount, status, created_at)
VALUES ('TX12345', 'USER001', 15000.00, 'pending', 1234567890);
GO
```

**Expected Results:**

1. Check the BI logs - you should see:
   - `Create transaction event received. Transaction Id: TX12345`
   - `Email sent. Message ID: <gmail_message_id>`

2. Check your email - you should receive an alert with:
   - **Subject**: "Fraud Alert: Suspicious Transaction Detected"
   - **Body**: Details of the fraudulent transaction in JSON format
