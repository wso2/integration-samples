# Setup Instructions

Follow these instructions to configure and deploy the Salesforce Leads to Google Sheets integration on WSO2 Devant.

---

<details>
<summary><strong>Salesforce Setup Guide</strong></summary>

## Step 1: Create a Salesforce Connected App

1. Log in to your Salesforce account
2. Navigate to **Setup** (gear icon in top right)
3. In the Quick Find box, search for **App Manager**
4. Click **New Connected App**

## Step 2: Configure the Connected App

Fill in the following details:

**Basic Information:**
- **Connected App Name**: `Ballerina Salesforce Integration`
- **API Name**: Auto-populated (e.g., `Ballerina_Salesforce_Integration`)
- **Contact Email**: Your email address

**API (Enable OAuth Settings):**
- Check **Enable OAuth Settings**
- **Callback URL**: `https://login.salesforce.com/services/oauth2/callback`
- **Selected OAuth Scopes**:
  - `Access and manage your data (api)`
  - `Perform requests on your behalf at any time (refresh_token, offline_access)`

Click **Save** and then **Continue**.

## Step 3: Retrieve OAuth Credentials

1. After saving, you'll see the **Consumer Key** (Client ID) and **Consumer Secret** (Client Secret)
2. Copy these values - you'll need them for configuration
3. Click **Manage Consumer Details** to view the Consumer Secret

## Step 4: Obtain Refresh Token

You can obtain a refresh token using one of these methods:

**Method A: Using cURL**
```bash
# Step 1: Get authorization code (paste this URL in browser)
https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=https://login.salesforce.com/services/oauth2/callback

# Step 2: Exchange code for tokens
curl -X POST https://login.salesforce.com/services/oauth2/token \
  -d "grant_type=authorization_code" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "redirect_uri=https://login.salesforce.com/services/oauth2/callback" \
  -d "code=AUTHORIZATION_CODE_FROM_STEP_1"
```

**Method B: Using Postman**
1. Create a new POST request to `https://login.salesforce.com/services/oauth2/token`
2. Set body parameters:
   - `grant_type`: `authorization_code`
   - `client_id`: Your Consumer Key
   - `client_secret`: Your Consumer Secret
   - `redirect_uri`: `https://login.salesforce.com/services/oauth2/callback`
   - `code`: Authorization code from browser redirect
3. Send request and copy the `refresh_token` from response

## Step 5: Note Your Salesforce Instance URL

Your base URL is typically in the format:
- Production: `https://yourcompany.my.salesforce.com`
- Sandbox: `https://yourcompany--sandbox.my.salesforce.com`

You can find this in your browser's address bar when logged into Salesforce.

</details>

---

<details>
<summary><strong>Google Sheets Setup Guide</strong></summary>

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Enter a project name (e.g., `Salesforce Sheets Integration`)
4. Click **Create**

## Step 2: Enable Required APIs

1. In the Google Cloud Console, navigate to **APIs & Services** → **Library**
2. Search for and enable:
   - **Google Sheets API**
   - **Google Drive API**

## Step 3: Create OAuth 2.0 Credentials

1. Navigate to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. If prompted, configure the **OAuth consent screen**:
   - User Type: **External**
   - App name: `Salesforce Sheets Integration`
   - User support email: Your email
   - Developer contact: Your email
   - Click **Save and Continue**
   - Scopes: Click **Add or Remove Scopes** and add:
     - `https://www.googleapis.com/auth/spreadsheets`
     - `https://www.googleapis.com/auth/drive`
   - Click **Save and Continue**
   - Test users: Add your email
   - Click **Save and Continue**

4. Back in **Credentials**, click **Create Credentials** → **OAuth client ID**
5. Application type: **Web application**
6. Name: `Ballerina Integration Client`
7. Authorized redirect URIs: `https://developers.google.com/oauthplayground`
8. Click **Create**
9. Copy the **Client ID** and **Client Secret**

## Step 4: Obtain Refresh Token

1. Go to [OAuth 2.0 Playground](https://developers.google.com/oauthplayground)
2. Click the gear icon (⚙️) in the top right
3. Check **Use your own OAuth credentials**
4. Enter your **OAuth Client ID** and **OAuth Client Secret**
5. Close the settings

6. In **Step 1 - Select & authorize APIs**:
   - Scroll to **Google Sheets API v4**
   - Select `https://www.googleapis.com/auth/spreadsheets`
   - Scroll to **Drive API v3**
   - Select `https://www.googleapis.com/auth/drive`
   - Click **Authorize APIs**

7. Sign in with your Google account and grant permissions

8. In **Step 2 - Exchange authorization code for tokens**:
   - Click **Exchange authorization code for tokens**
   - Copy the **Refresh token** from the response

## Step 5: (Optional) Create Target Spreadsheet

If you want to use an existing spreadsheet:
1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet or open an existing one
3. Copy the spreadsheet ID from the URL:
   - URL format: `https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit`
   - The `SPREADSHEET_ID` is the long string between `/d/` and `/edit`

</details>

---

<details>
<summary><strong>Additional Configurations</strong></summary>

## Spreadsheet Configuration

### `spreadsheetId` (optional)
- **Type**: string
- **Default**: `()` (creates new spreadsheet)
- **Description**: The ID of an existing Google Sheets spreadsheet. If not provided, a new spreadsheet will be created with each execution.
- **Example**: `"1abc123xyz456def789ghi"`

### `tabName` (optional)
- **Type**: string
- **Default**: `"Leads"`
- **Description**: The name of the sheet tab where leads will be written. Only used when `splitByField` is `NONE`.
- **Example**: `"Salesforce Leads"`

## Query Configuration

### `soqlFilter` (optional)
- **Type**: string
- **Default**: `""` (no additional filter)
- **Description**: Additional SOQL WHERE clause fragment to filter leads. Do not include the "WHERE" keyword.
- **Examples**:
  - `"Rating = 'Hot'"`
  - `"Industry = 'Technology' AND AnnualRevenue > 1000000"`
  - `"CreatedDate = THIS_MONTH"`

### `fieldMapping` (optional)
- **Type**: string array
- **Default**: `["Id", "FirstName", "LastName", "Email", "Phone", "Company", "Title", "Status", "LeadSource", "Industry", "Rating", "CreatedDate", "LastModifiedDate"]`
- **Description**: Ordered list of Salesforce Lead field API names to export as columns. The order determines the column order in the spreadsheet.
- **Example**: `["Id", "Email", "Company", "Status", "CreatedDate"]`
- **Available Fields**: Any standard or custom Lead field API name (e.g., `Custom_Field__c`)

## Sync Configuration

### `syncMode` (optional)
- **Type**: string
- **Default**: `"APPEND"`
- **Options**:
  - `"APPEND"`: Creates a new sheet with timestamped name and adds lead data
  - `"FULL_REPLACE"`: Completely replaces entire spreadsheet with fresh data (destructive)
  - `"UPSERT_BY_EMAIL"`: Updates existing leads by email, appends new ones (requires spreadsheetId and Email in fieldMapping)
- **Description**: Determines how data is written to the spreadsheet.
- **Requirements**:
  - APPEND: Works with or without spreadsheetId
  - FULL_REPLACE: Works with or without spreadsheetId (deletes all sheets if existing)
  - UPSERT_BY_EMAIL: **MUST** provide spreadsheetId and include "Email" in fieldMapping

### `includeConverted` (optional)
- **Type**: boolean
- **Default**: `false`
- **Description**: Whether to include leads that have been converted to contacts/accounts/opportunities.
- **Example**: `true` (includes converted leads)

### `splitBy` (optional)
- **Type**: string
- **Default**: `""` (empty string, disabled)
- **Description**: Split leads into multiple sheets by field value. Set to a field name from fieldMapping (e.g., "LeadSource", "Status", "Industry") or leave empty to disable.
- **Examples**:
  - `"LeadSource"`: Creates sheets like "Leads - Web", "Leads - Phone Inquiry"
  - `"Status"`: Creates sheets like "Leads - Open", "Leads - Qualified"
  - `""`: All leads in single sheet (default)
- **Note**: Works with all sync modes (APPEND, FULL_REPLACE, UPSERT_BY_EMAIL)

### `enableIncrementalSync` (optional)
- **Type**: boolean
- **Default**: `false`
- **Description**: Enable incremental sync to only fetch leads modified since last sync.
- **Note**: When enabled, check logs for next timestamp value to use.

### `lastSyncTimestamp` (optional)
- **Type**: string
- **Default**: `""` (no incremental sync)
- **Description**: ISO 8601 timestamp for incremental sync. Only leads modified after this timestamp will be fetched. Used when enableIncrementalSync is true.
- **Format**: `YYYY-MM-DDTHH:mm:ssZ`
- **Examples**:
  - `"2025-01-01T00:00:00Z"`
  - `"2025-06-15T14:30:00Z"`
- **Note**: Update this value after each successful sync with the timestamp from logs.

### `timezone` (optional)
- **Type**: string
- **Default**: `"UTC"`
- **Description**: IANA timezone string used for formatting timestamps in spreadsheet names.
- **Examples**:
  - `"America/New_York"`
  - `"Europe/London"`
  - `"Asia/Tokyo"`
  - `"America/Los_Angeles"`
  - `"Asia/Colombo"`

### `enableAutoFormat` (optional)
- **Type**: boolean
- **Default**: `true`
- **Description**: Enable auto-formatting to prepare sheets for optimal viewing. Headers are placed in first row.
- **Note**: Manual bold formatting and row freezing can be applied in Google Sheets UI.

### `timeframe` (optional)
- **Type**: string
- **Default**: `"ALL"`
- **Options**: `"ALL"`, `"YESTERDAY"`, `"LAST_WEEK"`, `"LAST_MONTH"`, `"LAST_YEAR"`
- **Description**: Timeframe filter based on CreatedDate to fetch leads from specific time periods.
- **Examples**:
  - `"ALL"`: No timeframe filtering (default)
  - `"YESTERDAY"`: Leads created yesterday
  - `"LAST_WEEK"`: Leads created last week (Monday to Sunday)
  - `"LAST_MONTH"`: Leads created last month
  - `"LAST_YEAR"`: Leads created last year

</details>

---

## Deployment Steps

1. **Configure Salesforce Credentials**:
   - `salesforceRefreshToken`: Refresh token from Step 4 above
   - `salesforceClientId`: Consumer Key from Salesforce Connected App
   - `salesforceClientSecret`: Consumer Secret from Salesforce Connected App
   - `salesforceRefreshUrl`: `https://login.salesforce.com/services/oauth2/token`
   - `salesforceBaseUrl`: Your Salesforce instance URL

2. **Configure Google Credentials**:
   - `googleRefreshToken`: Refresh token from OAuth Playground
   - `googleClientId`: OAuth Client ID from Google Cloud Console
   - `googleClientSecret`: OAuth Client Secret from Google Cloud Console

3. **Configure Optional Settings**: Adjust any additional configurations as needed

4. **Set Up Cron Schedule**: Configure the execution schedule (e.g., daily, hourly)

5. **Deploy**: Click Deploy to activate the integration

6. **Monitor**: Check execution logs to verify successful data export

---

## Troubleshooting

### Salesforce Connection Issues
- Verify your Salesforce credentials are correct
- Ensure the Connected App has the required OAuth scopes
- Check that your refresh token hasn't expired
- Verify your Salesforce instance URL is correct

### Google Sheets Connection Issues
- Verify your Google OAuth credentials are correct
- Ensure the required APIs (Sheets + Drive) are enabled
- Check that your refresh token hasn't expired
- Verify the spreadsheet ID exists and is accessible

### No Leads Exported
- Check your SOQL filter syntax
- Verify `includeConverted` setting matches your needs
- Check `lastSyncTimestamp` isn't filtering out all leads
- Review Salesforce query logs for errors

### Performance Issues
- Reduce the number of fields in `fieldMapping`
- Use `lastSyncTimestamp` for incremental syncs
- Add more specific `soqlFilter` to reduce result set
- Consider splitting large exports into multiple scheduled runs
