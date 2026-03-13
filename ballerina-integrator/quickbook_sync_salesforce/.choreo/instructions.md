# QuickBooks to Salesforce Sync - Instructions

## What It Does

- Receives real-time webhook notifications from QuickBooks when customers are created or updated
- Creates or updates matching Salesforce Account records
- Maintains parent-child customer hierarchy and applies fallback behavior when custom field issues occur

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
3. Create required custom field in Account object:
   - Field Type: Text
   - Field Label: Quickbooks Sync
   - Field Name: QuickbooksSync (API Name: `QuickbooksSync__c`)
   - Length: 255

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>

<summary>QuickBooks Setup Guide</summary>

1. A QuickBooks Online account with API access
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Realm ID (Company ID)
3. Webhook configuration:
   - Public HTTPS webhook endpoint
   - Webhook verification token
   - Customer entity subscription

This integration uses refresh token flow for auth. [Learn how to set up QuickBooks OAuth](https://developer.intuit.com/app/developer/qbo/docs/develop/authentication-and-authorization/oauth-2.0).

</details>

<details>

<summary>Additional Configurations</summary>

1. `salesforceClientId`, `salesforceClientSecret`, `salesforceRefreshToken`, `salesforceRefreshUrl`, `salesforceBaseUrl`
   - Credentials and endpoint values required to authenticate and call Salesforce APIs.
2. `quickbooksClientId`, `quickbooksClientSecret`, `quickbooksRefreshToken`, `quickbooksRealmId`, `quickbooksBaseUrl`
   - Credentials and endpoint values required to authenticate and call QuickBooks APIs.
3. `webhookPort`, `webhookVerifyToken`
   - Service port and verification token used by the QuickBooks webhook endpoint.


</details>
