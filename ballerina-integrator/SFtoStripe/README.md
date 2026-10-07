# Salesforce to Stripe Customer Sync Integration

Description

This integration listens for Salesforce Account and Contact creation, update, and deletion events and creates or updates corresponding customers in Stripe.

What it does

- When an Account or Contact is created in Salesforce, the integration creates a customer in Stripe with the customer details
- When updated in Salesforce, the corresponding Stripe customer is updated
- When deleted in Salesforce, the Stripe customer is deleted
- Stripe customer ID is automatically written back to Salesforce for future reference

Prerequisites

Before running this integration, you need:

Salesforce Setup

- Enable Change Data Capture for Account and Contact objects:
  - Navigate to Setup > Change Data Capture
  - Move Account and Contact to "Selected Entities"
  - Click Save
- Create a custom field `Stripe_Customer_Id__c` (Text, 255 chars) on Account and Contact objects
- (Optional) Create a custom field `Email__c` (Email, 255 chars) on Account object if you want to sync account emails to Stripe
- (Optional) Create a custom field `AccountStatus__c` on Account object if you want to use the accountStatusFilter configuration
- Create a Connected App for OAuth2 credentials:
  - Navigate to Setup > Apps > App Manager
  - Create new Connected App and note the Client ID, Client Secret, and Refresh Token

Stripe Setup

- Log in to your Stripe account and navigate to the Developers section
- Click on API keys in the left sidebar
- Copy the value of the Secret key

Configuration

The following configurations are required for the integration:

Salesforce Configuration

- refreshToken: Your Salesforce OAuth2 refresh token
- clientId: Your Salesforce OAuth2 client ID
- clientSecret: Your Salesforce OAuth2 client secret
- refreshUrl: Salesforce OAuth2 token endpoint (https://login.salesforce.com/services/oauth2/token)
- baseUrl: Your Salesforce instance URL (https://your-org.my.salesforce.com)


Stripe Configuration
- apiKey: The Stripe Secret API key obtained from the Stripe setup

Deploying on Devant

- Sign in to your Devant account
- Create a new Integration and follow instructions in Devant Documentation to import this repository
- Select the Technology as WSO2 Integrator: BI
- Choose the Integration Type as Automation and click Create
- Once the build is successful, click Configure to Continue and set the required environment variables for Salesforce and Stripe credentials
- Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well
