# HubSpot Contacts to Google Sheets Integration

## Description

This integration fetches contacts from HubSpot and synchronizes them to a Google Sheets spreadsheet. The integration runs once per execution and supports incremental synchronization to ensure that only new or modified contacts are processed.

Contacts are routed to different sheets based on their lifecycle stage, and existing records are updated using email as the unique identifier.

### What It Does

- Fetches contacts from HubSpot and syncs them to Google Sheets
- Routes contacts to sheet tabs using lifecycle stage
- Uses email-based upsert to avoid duplicates (`upsert`, `append`, or `replace`)
- Supports incremental sync with optional HubSpot property filtering
- Runs once per execution (scheduling is handled externally) with configurable field mapping

## Prerequisites

Before running this integration, you need:

### HubSpot Setup

1. A HubSpot account with CRM access
2. A Private App with the following scope:
   - `crm.objects.contacts.read`
3. Access Token generated from the private app

This integration uses a HubSpot Private App token for authentication. [Learn how to create a HubSpot Private App](https://developers.hubspot.com/docs/api/private-apps).

### Google Sheets Setup

1. A Google Cloud project with Google Sheets API enabled
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
3. Scopes Required:
   - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration

The following configurations are required to connect to HubSpot and Google Sheets.

### HubSpot Credentials

- `hubspotAccessToken` - Your HubSpot Private App access token

### Google Credentials

- `googleRefreshToken` - Your Google OAuth2 refresh token
- `googleClientId` - Your Google OAuth2 client ID
- `googleClientSecret` - Your Google OAuth2 client secret

### Spreadsheet Settings

- `spreadsheetId` - The ID of your target Google Spreadsheet

Each HubSpot lifecycle stage routes to its own sheet by default:

| Configurable | Lifecycle Stage | Default Sheet Name |
|---|---|---|
| `subscriberSheetName` | Subscriber | `Subscribers` |
| `leadSheetName` | Lead | `Leads` |
| `marketingqualifiedleadSheetName` | Marketing Qualified Lead | `MQLs` |
| `salesqualifiedleadSheetName` | Sales Qualified Lead | `SQLs` |
| `opportunitySheetName` | Opportunity | `Opportunities` |
| `customerSheetName` | Customer | `Customers` |
| `evangelistSheetName` | Evangelist | `Evangelists` |
| `otherSheetName` | Other | `Others` |
| `defaultSheetName` | Any unrecognised stage | `Sheet1` |

> **Tip:** Set multiple stage sheet names to the **same value** to merge them into one sheet. For example, to put leads and MQLs together set both `leadSheetName` and `marketingqualifiedleadSheetName` to `Leads`. To send **all contacts into a single sheet**, set every sheet name to the same value.

### Sync Settings

- `syncMode` - How contacts are written to the sheet:
  - `upsert` *(default)* — update the row if the email already exists, insert if not
  - `append` — always insert a new row, never check for duplicates
  - `replace` — clear the sheet first, then write all contacts fresh
- `fields` - List of HubSpot contact properties to export (e.g., `["email", "firstname", "lastname", "phone"]`)
- `maxRows` - Maximum number of contacts to process per run (`0` for unlimited)
- `lastSyncTimestamp` - Timestamp of the last sync; leave empty for a full initial sync
- `contactFilterProperty` - Optional HubSpot property name to filter contacts by
- `contactFilterValue` - Optional value to match for the filter property

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for HubSpot and Google Sheets credentials.
6. Click **Schedule** to schedule the automation.
7. In the **BY INTERVAL** tab, select the desired interval unit from the dropdown.
8. Set the desired frequency for the integration to run and click **Update**.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.