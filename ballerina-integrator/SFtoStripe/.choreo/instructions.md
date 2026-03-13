# Salesforce to Stripe Customer Sync Integration

## What It Does

This integration listens for Salesforce Account and Contact creation, update, and deletion events and automatically syncs them to Stripe:

- **Create**: When an Account or Contact is created in Salesforce, a corresponding customer is created in Stripe
- **Update**: When records are updated in Salesforce, the corresponding Stripe customer is updated with new information
- **Delete**: When records are deleted from Salesforce, the corresponding Stripe customer is deleted
- **Writeback**: Stripe customer IDs are automatically written back to Salesforce for future reference

## Prerequisites

<details>
<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. **Enable Change Data Capture (CDC)**:
   - Navigate to Setup > Change Data Capture
   - Move **Account** and **Contact** to "Selected Entities"
   - Click Save
3. **Create Custom Field** `Stripe_Customer_Id__c` (Text, 255 chars):
   - On Account object
   - On Contact object
4. **Create OAuth2 Connected App**:
   - Navigate to Setup > Apps > App Manager
   - Create new Connected App and note:
     - Client ID
     - Client Secret
     - Refresh Token

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>
<summary>Stripe Setup Guide</summary>

1. A Stripe account with API access
2. **Obtain Secret API Key**:
   - Log in to your Stripe account
   - Navigate to Developers section
   - Click on API keys in the left sidebar
   - Copy the **Secret key** (not the Publishable key)

</details>

<details>
<summary>Configuration Options</summary>

1. **syncDirection** (Default: SF_TO_STRIPE)
   - Possible values:
     - `SF_TO_STRIPE`: Sync only Salesforce changes to Stripe
     - `STRIPE_TO_SF`: Sync only Stripe changes to Salesforce
     - `BIDIRECTIONAL`: Sync changes in both directions

2. **sourceObject** (Default: BOTH)
   - Possible values:
     - `ACCOUNT`: Only sync Salesforce Accounts
     - `CONTACT`: Only sync Salesforce Contacts
     - `BOTH`: Sync both Accounts and Contacts

3. **matchKey** (Default: EMAIL)
   - Possible values:
     - `EMAIL`: Match customers by email address
     - `EXTERNAL_ID`: Match customers by external ID field

4. **writeBackStripeId** (Default: true)
   - Write the Stripe customer ID back to the Salesforce `Stripe_Customer_Id__c` field

5. **deleteStripeCustomerOnSalesforceDelete** (Default: true)
   - Delete the Stripe customer when the Salesforce record is deleted

6. **recordTypeFilter** (Optional)
   - Filter which Salesforce record types to sync

7. **accountStatusFilter** (Optional)
   - Filter Accounts by specific status values

</details>

## Configuration Setup

### Step 1: Salesforce Configuration
1. Log in to Salesforce and navigate to Setup
2. Enable Change Data Capture:
   - Go to Setup > Change Data Capture
   - Move Account and Contact to Selected Entities
   - Save
3. Create custom field `Stripe_Customer_Id__c`:
   - Go to Account object > Fields & Relationships
   - Create new field (Text, 255 chars)
   - Repeat for Contact object
4. Create a Connected App:
   - Go to Apps > App Manager
   - Create new Connected App
   - Note the Client ID, Client Secret
   - Generate and save a refresh token

### Step 2: Stripe Configuration
1. Log in to your Stripe account
2. Go to Developers > API keys
3. Copy the Secret key (starts with `sk_`)

### Step 3: Environment Variables
Set the following environment variables in your deployment platform:

**Salesforce:**
- `SALESFORCE_BASE_URL`: Your Salesforce instance URL (e.g., https://your-org.my.salesforce.com)
- `SALESFORCE_CLIENT_ID`: Salesforce OAuth2 Client ID
- `SALESFORCE_CLIENT_SECRET`: Salesforce OAuth2 Client Secret
- `SALESFORCE_REFRESH_TOKEN`: Salesforce OAuth2 Refresh Token
- `SALESFORCE_REFRESH_URL`: https://login.salesforce.com/services/oauth2/token

**Stripe:**
- `STRIPE_API_KEY`: Stripe Secret API key

**Optional Configuration:**
- `SYNC_DIRECTION`: SF_TO_STRIPE, STRIPE_TO_SF, or BIDIRECTIONAL (default: SF_TO_STRIPE)
- `SOURCE_OBJECT`: ACCOUNT, CONTACT, or BOTH (default: BOTH)
- `MATCH_KEY`: EMAIL or EXTERNAL_ID (default: EMAIL)
- `WRITE_BACK_STRIPE_ID`: true or false (default: true)
- `DELETE_STRIPE_CUSTOMER_ON_SALESFORCE_DELETE`: true or false (default: true)

## Deployment

This integration is designed to be deployed on Choreo or similar platforms. Ensure all environment variables are properly configured before deployment.

