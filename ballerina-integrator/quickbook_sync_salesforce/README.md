# QuickBooks to Salesforce Sync

## Description

This integration syncs QuickBooks customers to Salesforce accounts in real-time via webhooks. It provides a production-ready solution for maintaining synchronized customer data between QuickBooks Online and Salesforce, with support for parent-child relationships, conflict resolution, and automatic fallback mechanisms.

### What It Does

- Receives real-time webhook notifications from QuickBooks when customers are created or updated
- Automatically creates or updates corresponding Salesforce Account records
- Maintains parent-child relationships between QuickBooks sub-customers and Salesforce account hierarchy
- Stores QuickBooks customer ID in Salesforce custom field for proper linking linking
- Handles missing custom field scenarios with intelligent fallback logic



## Features

✅ **Real-time Sync** - Webhook-based synchronization from QuickBooks to Salesforce  
✅ **Duplicate Prevention** - Stores Salesforce Account ID in QuickBooks custom field  
✅ **Parent-Child Relationships** - Handles QuickBooks sub-customers → Salesforce account hierarchy  
✅ **Custom Field Validation** - Ensures custom field exists before syncing  
✅ **OAuth 2.0** - Secure authentication with automatic token refresh  

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
3. Required scopes: `api`, `refresh_token`, `offline_access`

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### QuickBooks Setup

1. A QuickBooks Online account with API access
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Realm ID (Company ID)
3. Webhook configuration:
   - Public HTTPS endpoint for webhooks (use ngrok for local testing)
   - Webhook verification token
   - Customer entity subscription

This integration uses refresh token flow for auth. [Learn how to set up QuickBooks OAuth](https://developer.intuit.com/app/developer/qbo/docs/develop/authentication-and-authorization/oauth-2.0).

### Additional Requirements

- Ballerina Swan Lake (2201.x or later)
- Public HTTPS endpoint for webhooks (use ngrok for local testing)

## Configuration

The following configurations are required to connect to Salesforce and QuickBooks.

### Salesforce Credentials

- `salesforceClientId` - Your Salesforce OAuth2 client ID
- `salesforceClientSecret` - Your Salesforce OAuth2 client secret
- `salesforceRefreshToken` - Your Salesforce OAuth2 refresh token
- `salesforceRefreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://login.salesforce.com/services/oauth2/token`)
- `salesforceBaseUrl` - Your Salesforce instance URL (e.g., `https://yourinstance.salesforce.com`)

### QuickBooks Credentials

- `quickbooksClientId` - Your QuickBooks OAuth2 client ID
- `quickbooksClientSecret` - Your QuickBooks OAuth2 client secret
- `quickbooksRefreshToken` - Your QuickBooks OAuth2 refresh token
- `quickbooksRealmId` - Your QuickBooks Company ID
- `quickbooksBaseUrl` - QuickBooks API base URL
  - Sandbox: `https://sandbox-quickbooks.api.intuit.com/v3/company`
  - Production: `https://quickbooks.api.intuit.com/v3/company`

### Webhook Configuration

- `webhookPort` - Port for webhook listener (default: 8080)
- `webhookVerifyToken` - Token for webhook verification

### Sync Configuration

- `conflictResolution` - Strategy for handling conflicts (options: `SOURCE_WINS`, `DESTINATION_WINS`, `MOST_RECENT`)
- `filterActiveOnly` - Only sync active customers (default: true)
- `createContact` - Create Salesforce contacts from customer data (default: false)

### Configuration File Example

Create a `Config.toml` file:

```toml
# Salesforce Configuration
salesforceClientId = "YOUR_SALESFORCE_CLIENT_ID"
salesforceClientSecret = "YOUR_SALESFORCE_CLIENT_SECRET"
salesforceRefreshToken = "YOUR_SALESFORCE_REFRESH_TOKEN"
salesforceRefreshUrl = "https://login.salesforce.com/services/oauth2/token"
salesforceBaseUrl = "https://yourinstance.salesforce.com"

# QuickBooks Configuration
quickbooksClientId = "YOUR_QUICKBOOKS_CLIENT_ID"
quickbooksClientSecret = "YOUR_QUICKBOOKS_CLIENT_SECRET"
quickbooksRefreshToken = "YOUR_QUICKBOOKS_REFRESH_TOKEN"
quickbooksRealmId = "YOUR_COMPANY_ID"
quickbooksBaseUrl = "https://sandbox-quickbooks.api.intuit.com/v3/company"

# Webhook Configuration
webhookPort = 8080
webhookVerifyToken = "YOUR_WEBHOOK_VERIFY_TOKEN"

# Sync Configuration
conflictResolution = "SOURCE_WINS"
filterActiveOnly = true
createContact = false
```

## Setup

### Custom Field Setup (REQUIRED)

**Salesforce Custom Field (REQUIRED for Updates):**

You MUST create this custom field in Salesforce Account object:

1. Go to Salesforce Setup → Object Manager → Account → Fields & Relationships
2. Click "New" to create a custom field
3. Field Type: **Text**
4. Field Label: **Quickbooks Sync**
5. Field Name: **QuickbooksSync** (API Name will be `QuickbooksSync__c`)
6. Length: **255**
7. Save and add to page layouts as needed

**If this field doesn't exist:**
- Create operations (without parent) will work with automatic fallback (creates without the field)
- **Create operations (with parent) will STOP immediately** - no sync performed
- **Update operations will STOP immediately** - no sync performed
- Parent customer hierarchy will not work
- Error message: "Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object"
- The field stores the QuickBooks customer ID for matching during updates and parent lookups

## Deploying on Devant

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Service` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and QuickBooks credentials.
6. Configure the webhook endpoint URL in QuickBooks Developer Portal to point to your deployed Devant service.
7. Test the integration by creating or updating a customer in QuickBooks.
8. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.

## Running Locally

```bash
# Build
bal build

# Run
bal run
```

**IMPORTANT**: Webhooks will NOT trigger automatically when the service starts. You must:
1. Start the service (`bal run`)
2. Make the service publicly accessible (use ngrok for local testing)
3. Configure webhook URL in QuickBooks Developer Portal
4. **Trigger a change in QuickBooks** (create or update a customer)
5. Then QuickBooks will send a webhook to your service

## API Endpoints

- `GET /` - Health check
- `GET /quickbooks/health` - Service health check
- `GET /quickbooks/webhook?verifyToken=TOKEN` - Webhook verification
- `POST /quickbooks/webhook` - Webhook event receiver

## Sync Behavior

### Create vs Update Operations

**Create Operation (WITHOUT Parent):**
- Directly creates a new Salesforce account without any search
- Fast and simple - no Salesforce queries
- Sets `QuickbooksSync__c` field with QuickBooks customer ID
- **Fallback**: If creation fails due to missing `QuickbooksSync__c` field, retries without it
- **Warning**: Without the custom field, updates and parent hierarchy will not work

**Create Operation (WITH Parent):**
- **REQUIRES** `QuickbooksSync__c` custom field in Salesforce
- Searches Salesforce by `QuickbooksSync__c` field to find parent account
- If parent found: Creates new account with parent relationship
- If parent not found: Fetches parent from QuickBooks and syncs it first (recursive)
- **If custom field missing**: Sync stops immediately with error (no fallback)
- Maintains parent-child hierarchy automatically

**Update Operation:**
- **REQUIRES** `QuickbooksSync__c` custom field in Salesforce
- Searches Salesforce by `QuickbooksSync__c` field (QuickBooks customer ID)
- If found: Updates the existing account (subject to conflict resolution)
- **If not found: Automatically falls back to Create operation** - creates new account
- **If custom field missing**: Sync stops immediately with error (no fallback)

### Custom Field Requirement

**You MUST create a custom field in Salesforce:**
1. Go to Salesforce Setup → Object Manager → Account → Fields & Relationships
2. Click "New" to create a custom field
3. Field Type: Text
4. Field Label: "Quickbooks Sync"
5. Field Name: `QuickbooksSync` (API Name will be `QuickbooksSync__c`)
6. Length: 255
7. Save and add to page layouts as needed

**If the custom field doesn't exist:**
- Create operations (without parent) will automatically retry without the field and succeed
- **Create operations (with parent) will stop immediately** - no sync performed
- **Update operations will stop immediately** - no sync performed
- Parent-child relationships will not work
- Error log: "Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object"

### Parent-Child Relationships
- QuickBooks sub-customers → Salesforce child accounts
- Parent accounts are synced first (recursive)
- Parent relationships are maintained using `QuickbooksSync__c` field lookup

## Logging

All operations are logged with timestamps:
- INFO: Normal operations
- WARN: Non-critical issues
- ERROR: Failures (sync continues)

## Production Considerations

✅ **Security**
- Use HTTPS for webhooks
- Rotate OAuth tokens regularly
- Store credentials securely (environment variables or secrets manager)

✅ **Monitoring**
- Monitor logs for errors
- Set up alerts for failed syncs
- Track webhook delivery failures

✅ **Performance**
- Webhook processing is synchronous but fast
- Parent customer syncs may cause cascading API calls
- Consider rate limits (QuickBooks: 500 req/min, Salesforce: varies by edition)

✅ **Error Handling**
- Failed QuickBooks updates don't fail the entire sync
- Comprehensive error logging
- Graceful degradation

## Testing the Integration

### Step 1: Start the Service
```bash
bal run
```

You should see:
```
###################################################################################################
QUICKBOOKS TO SALESFORCE SYNC SERVICE STARTING
###################################################################################################
SERVICE READY - Waiting for webhooks...
###################################################################################################
```

### Step 2: Make Service Publicly Accessible

**For Local Testing (using ngrok):**
```bash
# In a new terminal
ngrok http 8080
```

Copy the HTTPS URL (e.g., `https://xxxx.ngrok.io`)

### Step 3: Configure QuickBooks Webhook

1. Go to QuickBooks Developer Portal
2. Navigate to your app → Webhooks
3. Set webhook URL: `https://xxxx.ngrok.io/quickbooks/webhook`
4. Subscribe to "Customer" entity
5. Save and verify

### Step 4: Trigger a Webhook

**Webhooks are NOT sent automatically!** You must trigger them by:

1. **Go to QuickBooks Online**
2. **Create a new customer** OR **Update an existing customer**
3. **Save the changes**
4. **Check your service logs** - you should see:
   ```
   ###################################################################################################
   WEBHOOK RECEIVED FROM QUICKBOOKS
   ###################################################################################################
   ```

If you don't see logs, the webhook wasn't sent or didn't reach your service.

## Troubleshooting

### No Logs After Creating/Updating Customer in QuickBooks

**Common causes:**

1. **Service not running** - Check terminal shows "SERVICE READY"
2. **ngrok not running** - Check ngrok terminal shows "Forwarding"
3. **Wrong webhook URL in QuickBooks** - Must use ngrok HTTPS URL
4. **Webhook not verified** - Check QuickBooks Developer Portal shows "Active"
5. **Customer entity not subscribed** - Check webhook subscriptions include "Customer"

**How to verify:**

1. **Check service is running:**
   ```bash
   curl http://localhost:8080/quickbooks/health
   ```
   Should return: `{"status":"UP",...}`

2. **Check ngrok is forwarding:**
   - Open ngrok web interface: http://localhost:4040
   - You should see requests when you trigger webhooks

3. **Check QuickBooks webhook logs:**
   - Go to QuickBooks Developer Portal → Webhooks → Logs
   - Look for delivery attempts and response codes

### Webhook Not Receiving Events
- **Verify webhook URL is publicly accessible** (use ngrok HTTPS URL, not localhost)
- **Check QuickBooks webhook subscriptions are active** (should show "Active" status)
- **Verify `webhookVerifyToken` matches** between Config.toml and QuickBooks
- **Actually create/update a customer in QuickBooks** (webhooks don't trigger automatically)

### Custom Field Errors
- **Update operations failing** - Check logs for "Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce"
- **"Bad Request" errors** - Usually indicates the custom field is missing in Salesforce
- **"Error finding parent account with QuickBooks ID"** - Parent customer hierarchy requires the custom field
- **Parent-child relationships not working** - The custom field is required to link parent and child accounts
- Create the custom field in Salesforce: Setup → Object Manager → Account → Fields & Relationships → New
- Field Label: "Quickbooks Sync", Field Name: "QuickbooksSync" (API Name: `QuickbooksSync__c`)
- Field type must be "Text" with length 255
- Once created, update operations, parent lookups, and customer hierarchy will work automatically

### User Not Found During Update
- **"User not found in Salesforce"** - This warning appears when an Update operation can't find a matching account
- **Automatic fallback**: The integration automatically falls back to Create operation
- A new account will be created in Salesforce with the QuickBooks customer data
- This handles cases where customers were created directly in QuickBooks without prior sync

### Authentication Errors
- Refresh tokens may expire - regenerate them
- Verify client IDs and secrets are correct
- Check OAuth scopes are sufficient


