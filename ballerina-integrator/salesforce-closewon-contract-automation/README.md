# Salesforce to Docusign Contract Automation

## Description

This integration automatically sends Docusign contracts when Salesforce opportunities are marked as "Closed Won". It listens to Salesforce change events in real-time and triggers contract creation based on configurable business rules.

> **Note**: This integration uses OAuth2 authentication for the Salesforce event listener, which provides a more secure and modern authentication approach.

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
3. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)

This integration uses OAuth2 refresh token authentication for both API calls and the event listener. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Docusign Setup

1. A Docusign account (demo or production)
2. **Contract templates created with the following requirements**:
   - **MUST have at least one document attached** (PDF, Word, etc.)
   - **MUST have a recipient role named "Signer"** (case-sensitive)
   - Can have optional fields/tabs for pre-filling data
   - Template must be in "Active" status
3. OAuth2 credentials:
   - Account ID
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
4. Scopes Required:
   - `signature`
   - `impersonation`

**Important Template Setup**:
- Go to DocuSign > Templates > Create Template
- Add at least one document (upload PDF/Word file)
- Add a recipient role named "Signer" (this name must match exactly)
- Optionally add fields (text tabs) with labels matching your field mappings
- Save and activate the template
- Copy the Template ID from the URL

This integration uses the official `ballerinax/docusign.dsesign` connector with OAuth2 refresh token authentication for automatic token renewal. [Learn how to get Docusign credentials](https://developers.docusign.com/platform/auth/).

## Configuration

Configurations are organized by vendor-specific records for better structure and maintainability.

### Salesforce Configuration (`salesforceConfig`)

Record type: `SalesforceConfig`

- `clientId` - Your Salesforce OAuth2 client ID
- `clientSecret` - Your Salesforce OAuth2 client secret
- `refreshToken` - Your Salesforce OAuth2 refresh token
- `refreshUrl` - Salesforce OAuth2 token endpoint (default: `https://login.salesforce.com/services/oauth2/token`)
- `baseUrl` - Your Salesforce instance URL (default: `https://login.salesforce.com`)

**Important - Channel Configuration**: 
- The service in `main.bal` is configured to listen to `/data/ChangeEvents` by default (captures all object changes)
- To listen to a different channel, update the service declaration in `main.bal`:
  - For Opportunity-only events: `service "/data/OpportunityChangeEvent" on salesforceListener`
  - For custom channels: `service "/data/YourCustomChannel" on salesforceListener`
- The channel must be enabled in your Salesforce org's Change Data Capture settings

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

- `defaultTemplateId` - **REQUIRED** - Default Docusign template ID to use (e.g., "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
  - You can find your template ID in Docusign by going to Templates > Select your template > The ID is in the URL
  - Example URL: `https://demo.docusign.net/templates/details/a1b2c3d4-e5f6-7890-abcd-ef1234567890`
- `templateConfigs` - Array of template configurations for different product/deal types (optional)
  - `templateId` - Docusign template ID for this specific configuration
  - `productType` - Opportunity type to match (optional)
  - `dealType` - Deal type to match (optional)
  - `expirationDays` - Days until expiration reminder (optional)

**Example Configuration:**
```toml
[templateSettings]
defaultTemplateId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

[[templateSettings.templateConfigs]]
templateId = "template-for-enterprise"
productType = "Enterprise"
expirationDays = 7

[[templateSettings.templateConfigs]]
templateId = "template-for-standard"
productType = "Standard"
expirationDays = 3
```

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
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables:

### Required Environment Variables

**Salesforce Configuration:**
- `salesforceConfig.clientId` - Your Salesforce OAuth2 client ID
- `salesforceConfig.clientSecret` - Your Salesforce OAuth2 client secret
- `salesforceConfig.refreshToken` - Your Salesforce OAuth2 refresh token
- `salesforceConfig.refreshUrl` - Default: `https://login.salesforce.com/services/oauth2/token`
- `salesforceConfig.baseUrl` - Your Salesforce instance URL

**Docusign Configuration:**
- `docusignConfig.accountId` - Your Docusign account ID
- `docusignConfig.clientId` - Your Docusign OAuth2 client ID (Integration Key)
- `docusignConfig.clientSecret` - Your Docusign OAuth2 client secret
- `docusignConfig.refreshToken` - Your Docusign OAuth2 refresh token
- `docusignConfig.refreshUrl` - Default: `https://account-d.docusign.com/oauth/token` (demo) or `https://account.docusign.com/oauth/token` (production)
- `docusignConfig.baseUrl` - Default: `https://demo.docusign.net/restapi` (demo) or `https://na1.docusign.net/restapi` (production)

**Template Configuration:**
- `templateSettings.defaultTemplateId` - **REQUIRED** - Your Docusign template ID (find it in Docusign Templates section)

**Business Rules (Optional):**
- `businessRulesConfig.minimumDealValue` - Minimum opportunity amount (default: 0.0)
- `businessRulesConfig.signerRole` - Contact role for signer (default: "Primary Contact")
- `businessRulesConfig.contractSentStage` - Stage name after sending (default: "Contract Sent")

6. Click **Deploy** to deploy the integration.
7. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - Verify Salesforce OAuth credentials (client ID, client secret, refresh token)
   - Check OAuth token validity and refresh token
   - Ensure Connected App permissions are correct (API, Refresh Token, Access and manage your data)
   - Verify Docusign OAuth credentials (client ID, client secret, refresh token)
   - Ensure Docusign refresh URL matches your environment (demo vs production)

2. **Event Not Received**:
   - Verify Change Data Capture is enabled for Opportunity object in Salesforce
   - Check channel name configuration matches Salesforce setup
   - Review Salesforce event monitoring logs
   - Verify OAuth credentials have proper permissions for event streaming

3. **Docusign Errors**:
   - **"Template ID is empty"**: Configure `defaultTemplateId` in `templateSettings` configuration
   - **"ENVELOPE_IS_INCOMPLETE"**: This is the most common error. Causes:
     - **Template has NO documents attached** - Go to DocuSign > Templates > Select template > Add at least one document (PDF/Word)
     - Template is not in "Active" status - Activate the template in DocuSign
     - Template has no recipient roles defined
   - **"Bad Request"**: Common causes:
     - Template ID doesn't exist in your Docusign account
     - Template role name mismatch (template must have a role named "Signer" - case sensitive)
     - Field labels in template don't match configured field mappings
     - Invalid account ID
   - Verify template ID exists in your Docusign account (Templates > Select template > Check URL)
   - **Verify template has documents**: Templates > Select template > Documents tab > Must have at least 1 document
   - Check field names in template match configured field mappings
   - Ensure access token has required scopes (signature, impersonation)
   - Verify account ID is correct

4. **Contact Not Found**:
   - Ensure opportunity has contacts with the configured role
   - Check OpportunityContactRole records in Salesforce
   - Verify at least one contact is marked as primary

5. **Validation Errors**:
   - Check opportunity has required fields (Name, Amount)
   - Verify contact has valid email address
   - Ensure opportunity amount meets minimum threshold
