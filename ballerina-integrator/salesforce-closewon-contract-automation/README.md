# Salesforce to Docusign Contract Automation

## Description

This integration automatically sends Docusign contracts when Salesforce opportunities are marked as "Closed Won". It listens to Salesforce change events in real-time and triggers contract creation based on configurable business rules.

> **Important**: This integration requires **SOAP API to be enabled** in your Salesforce org for the event listener to work. If you see "SOAP API login() is disabled" error, go to Setup → Session Settings → Enable "Allow SOAP API login".

### What It Does

- Listens to Salesforce Opportunity change events and validates they meet business criteria (Closed Won stage, minimum deal value)
- Retrieves contact details based on configured signer role and selects the appropriate Docusign template
- Creates and sends Docusign envelope with pre-filled fields, configured signers, and CC recipients
- Updates Salesforce opportunity stage to track contract status

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. **Change Data Capture** enabled for the Opportunity object
3. **SOAP API enabled** - Required for the event listener (CometD protocol)
   - If you see "SOAP API login() is disabled" error, enable it in Setup → Session Settings → "Allow SOAP API login"
   - Alternatively, contact your Salesforce administrator to enable SOAP API
4. OAuth2 credentials for API calls:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
5. Username and password (with security token appended) for event listener

This integration uses OAuth2 refresh token authentication for API calls and username/password authentication for the event listener (CometD protocol). [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Docusign Setup

1. A Docusign account (demo or production)
2. Contract templates created with named fields
3. OAuth2 credentials:
   - Account ID
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
4. Scopes Required:
   - `signature`
   - `impersonation`

This integration uses the official `ballerinax/docusign.dsesign` connector with OAuth2 refresh token authentication for automatic token renewal. [Learn how to get Docusign credentials](https://developers.docusign.com/platform/auth/).

## Configuration

Configurations are organized by vendor-specific records for better structure and maintainability.

### Salesforce Configuration (`salesforceConfig`)

Record type: `SalesforceConfig`

- `username` - Your Salesforce username for listener authentication
- `password` - Your Salesforce password with security token appended (e.g., if password is "mypass" and token is "abc123", use "mypassabc123")
- `clientId` - Your Salesforce OAuth2 client ID
- `clientSecret` - Your Salesforce OAuth2 client secret
- `refreshToken` - Your Salesforce OAuth2 refresh token
- `refreshUrl` - Salesforce OAuth2 token endpoint (default: `https://login.salesforce.com/services/oauth2/token`)
- `baseUrl` - Your Salesforce instance URL (default: `https://login.salesforce.com`)
- `channelName` - Salesforce event channel to listen to (default: `/data/ChangeEvents`)

**Note**: The default channel `/data/ChangeEvents` captures all object changes. To listen to only Opportunity changes, set `channelName` to `/data/OpportunityChangeEvent`.

**Important**: The event listener uses SOAP API for authentication. If you encounter "SOAP API login() is disabled" error, you must enable SOAP API in your Salesforce org (Setup → Session Settings → "Allow SOAP API login").

### Docusign Configuration (`docusignConfig`)

Record type: `DocusignConfig`

- `accountId` - Your Docusign account ID
- `clientId` - Your Docusign OAuth2 client ID (Integration Key)
- `clientSecret` - Your Docusign OAuth2 client secret
- `refreshToken` - Your Docusign OAuth2 refresh token
- `refreshUrl` - Docusign OAuth2 token endpoint (default: `https://account-d.docusign.com/oauth/token` for demo, `https://account.docusign.com/oauth/token` for production)
- `baseUrl` - Docusign API base URL (default: `https://demo.docusign.net/restapi` for demo, `https://na1.docusign.net/restapi` for production)

### Template Configuration (`templateSettings`)

Record type: `TemplateSettings`

- `defaultTemplateId` - Default Docusign template ID to use
- `templateConfigs` - Array of template configurations for different product/deal types
  - `templateId` - Docusign template ID
  - `productType` - Opportunity type to match (optional)
  - `dealType` - Deal type to match (optional)
  - `expirationDays` - Days until expiration reminder (optional)

### Business Rules Configuration (`businessRulesConfig`)

Record type: `BusinessRulesConfig`

- `minimumDealValue` - Minimum opportunity amount to trigger contract (default: 0.0)
- `signerRole` - Contact role to use as signer (options: "Primary Contact", "Billing Contact", "Decision Maker", "Executive Sponsor")
- `ccRecipients` - Array of CC recipients
  - `email` - Recipient email address
  - `name` - Recipient name
- `fieldMappings` - Array of field mappings from Salesforce to Docusign
  - `opportunityField` - Salesforce Opportunity field name
  - `docusignField` - Docusign template field label
- `contractSentStage` - Opportunity stage to set after sending contract (default: "Contract Sent")
- `expirationReminderDays` - Default expiration reminder days (default: 3)

## Deploying on **WSO2 Integration Platform**

1. Sign in to your WSO2 Integration Platform account.
2. Create a new Integration to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Event Handler` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Docusign credentials.
6. Click **Deploy** to deploy the integration.
7. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - **SOAP API Disabled Error**: Enable SOAP API in Salesforce Setup → Session Settings → "Allow SOAP API login"
   - Verify Salesforce username/password and security token for listener
   - Verify Salesforce OAuth credentials (client ID, client secret, refresh token) for API calls
   - Check OAuth token validity and refresh token
   - Ensure Connected App permissions are correct (API, Refresh Token, Access and manage your data)
   - Verify Docusign OAuth credentials (client ID, client secret, refresh token)
   - Ensure Docusign refresh URL matches your environment (demo vs production)

2. **Event Not Received**:
   - Verify Change Data Capture is enabled for Opportunity object in Salesforce
   - Check channel name configuration matches Salesforce setup
   - Review Salesforce event monitoring logs
   - Ensure SOAP API is enabled for listener authentication
   - Verify username/password credentials have API access

3. **Docusign Errors**:
   - Verify template ID exists in your Docusign account
   - Check field names in template match configured field mappings
   - Ensure access token has required scopes
   - Verify account ID is correct

4. **Contact Not Found**:
   - Ensure opportunity has contacts with the configured role
   - Check OpportunityContactRole records in Salesforce
   - Verify at least one contact is marked as primary

5. **Validation Errors**:
   - Check opportunity has required fields (Name, Amount)
   - Verify contact has valid email address
   - Ensure opportunity amount meets minimum threshold
