# Salesforce to Stripe Customer Sync Integration
## What It Does

This integration listens for Salesforce Account and Contact creation, update, and deletion events and automatically syncs them to Stripe:

- **Create**: When an Account or Contact is created in Salesforce, a corresponding customer is created in Stripe
- **Update**: When records are updated in Salesforce, the corresponding Stripe customer is updated with new information
- **Delete**: When records are deleted from Salesforce, the corresponding Stripe customer is deleted
- **Writeback**: Stripe customer IDs are automatically written back to Salesforce for future reference

## Configuration details

<details>
<summary>Salesforce Setup Guide</summary>
1. A Salesforce account with API access and Change Data Capture enabled
2. OAuth2 credentials:
  - clientId
  - clientSecret
  - refreshToken
  - refreshUrl
  - baseUrl (your Salesforce instance URL)
3. Change Data Capture must be enabled for the **Account** and **Contact** objects
4. **Create Custom Field** `Stripe_Customer_Id__c` (Text, 255 chars):
   - On Account object
   - On Contact object
5. Optional: To sync account emails to Stripe, create a custom field `Email__c` (Email, 255 chars) on the Account object.
6. Optional: Create a custom field `AccountStatus__c` on Account object to use the accountStatusFilter configuration

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).
</details>


<details>
<summary>Stripe Setup Guide</summary>
1. Log in to your Stripe account and navigate to the **Developers** section.
2. Click on **API keys** in the left sidebar.
3. Copy the value of the **Secret key**. This should be the `apiKey` configuration.
</details>

<details>
<summary>Configuration Options</summary>

1. **sourceObject** (Default: BOTH)
   - Possible values:
     - `ACCOUNT`: Only sync Salesforce Accounts
     - `CONTACT`: Only sync Salesforce Contacts
     - `BOTH`: Sync both Accounts and Contacts

2. **matchKey** (Default: EMAIL)
    - Possible values:
      - `EMAIL`: Match customers by email address
      - `SALESFORCE_ID`: Uses the Salesforce record Id

3. **writeBackStripeId** (Default: true)
   - Write the Stripe customer ID back to the Salesforce `Stripe_Customer_Id__c` field

4. **deleteStripeCustomerOnSalesforceDelete** (Default: true)
   - Delete the Stripe customer when the Salesforce record is deleted

5. **recordTypeFilter** (Optional)
   - Filter which Salesforce record types to sync

6. **accountStatusFilter** (Optional)
   - Filter Accounts by specific status values

</details>
