# Salesforce to DocuSign Contract Automation

## Description

This integration automatically sends DocuSign contracts when Salesforce opportunities are marked as "Closed Won". It listens to Salesforce change events in real-time and triggers contract creation based on configurable business rules.

### What It Does

- Listens to Salesforce Opportunity change events using Change Data Capture
- Validates opportunities meet business criteria (stage = "Closed Won", minimum deal value)
- Retrieves the appropriate contact based on configured signer role
- Selects the correct DocuSign template based on opportunity type
- Creates and sends DocuSign envelope with:
  - Pre-filled fields from Salesforce opportunity data
  - Configured signer (Primary Contact, Billing Contact, etc.)
  - CC recipients (Legal, Sales Ops, Finance)
  - Custom email subject and routing order
- Updates Salesforce opportunity stage to "Contract Sent"
- Provides comprehensive error handling and logging

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. **Change Data Capture** enabled for the Opportunity object
3. OAuth2 credentials for API calls:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
4. Username and password (with security token) for event listener

This integration uses both username/password authentication for the listener and refresh token flow for API calls. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### DocuSign Setup

1. A DocuSign account (demo or production)
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

This integration uses the official `ballerinax/docusign.dsesign` connector with OAuth2 refresh token authentication for automatic token renewal. [Learn how to get DocuSign credentials](https://developers.docusign.com/platform/auth/).

## Configuration

The following configurations are required to connect to Salesforce and DocuSign.

### Salesforce Credentials

- `salesforceUsername` - Your Salesforce username for listener authentication
- `salesforcePassword` - Your Salesforce password with security token appended
- `salesforceClientId` - Your Salesforce OAuth2 client ID
- `salesforceClientSecret` - Your Salesforce OAuth2 client secret
- `salesforceRefreshToken` - Your Salesforce OAuth2 refresh token
- `salesforceRefreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://login.salesforce.com/services/oauth2/token`)
- `salesforceBaseUrl` - Your Salesforce instance URL (e.g., `https://login.salesforce.com`)
- `salesforceChannelName` - Change event channel (default: `/data/ChangeEvents`)

### DocuSign Credentials

- `docusignAccountId` - Your DocuSign account ID
- `docusignClientId` - Your DocuSign OAuth2 client ID (Integration Key)
- `docusignClientSecret` - Your DocuSign OAuth2 client secret
- `docusignRefreshToken` - Your DocuSign OAuth2 refresh token
- `docusignRefreshUrl` - DocuSign OAuth2 token endpoint (e.g., `https://account-d.docusign.com/oauth/token` for demo, `https://account.docusign.com/oauth/token` for production)
- `docusignBaseUrl` - DocuSign API base URL (e.g., `https://demo.docusign.net/restapi` for demo, `https://na1.docusign.net/restapi` for production)

### Template Configuration

- `defaultTemplateId` - Default DocuSign template ID to use
- `templateConfigs` - Array of template configurations for different product/deal types
  - `templateId` - DocuSign template ID
  - `productType` - Opportunity type to match (optional)
  - `dealType` - Deal type to match (optional)
  - `expirationDays` - Days until expiration reminder (optional)

### Business Rules

- `minimumDealValue` - Minimum opportunity amount to trigger contract (default: 0.0)
- `signerRole` - Contact role to use as signer (options: "Primary Contact", "Billing Contact", "Decision Maker", "Executive Sponsor")
- `ccRecipients` - Array of CC recipients
  - `email` - Recipient email address
  - `name` - Recipient name
- `fieldMappings` - Array of field mappings from Salesforce to DocuSign
  - `opportunityField` - Salesforce Opportunity field name
  - `docusignField` - DocuSign template field label
- `contractSentStage` - Opportunity stage to set after sending contract (default: "Contract Sent")
- `expirationReminderDays` - Default expiration reminder days (default: 3)

## Deploying on **Choreo**

1. Sign in to your Choreo account.
2. Create a new Integration and follow instructions in [Choreo Documentation](https://wso2.com/choreo/docs/) to import this repository.
3. Select the **Technology** as `Ballerina`.
4. Choose the **Integration** Type as `Service` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and DocuSign credentials.
6. Click **Deploy** to deploy the integration.
7. The integration will start listening to Salesforce change events automatically.
8. Monitor logs to verify successful contract dispatch.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.

## Running Locally

1. Clone this repository
2. Create a `Config.toml` file with your credentials (see `Config.toml` for sample configuration)
3. Run the integration:

```bash
bal run
```

4. The integration will start listening to Salesforce change events
5. Update an opportunity to "Closed Won" stage in Salesforce to trigger contract dispatch
6. Check logs for processing status and DocuSign envelope ID

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - Verify Salesforce credentials and security token
   - Check OAuth token validity and refresh token
   - Ensure Connected App permissions are correct
   - Verify DocuSign OAuth credentials (client ID, client secret, refresh token)
   - Ensure DocuSign refresh URL matches your environment (demo vs production)

2. **Event Not Received**:
   - Verify Change Data Capture is enabled for Opportunity object in Salesforce
   - Check channel name configuration matches Salesforce setup
   - Review Salesforce event monitoring logs
   - Ensure listener credentials have API access

3. **DocuSign Errors**:
   - Verify template ID exists in your DocuSign account
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
