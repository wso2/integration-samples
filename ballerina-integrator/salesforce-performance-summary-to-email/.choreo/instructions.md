## What It Does

- Validates and executes a Salesforce Analytics report using the report ID
- Calculates current and previous period date ranges (monthly, quarterly, or yearly)
- Extracts and parses pre-aggregated metrics from Salesforce report fact maps
- Compares current period performance against previous period with percentage changes
- Sends a formatted HTML email with performance metrics via Mailchimp Transactional
- Fails gracefully if the report is inaccessible or contains no metrics

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. An existing Salesforce Analytics Report ID (e.g., `00O5g000007QtXXEA0`)
   - Find this by navigating to Reports in Salesforce and viewing the report URL
   - The report ID is the alphanumeric string after `/lightning/r/Report/`
3. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)

This automation uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>

<summary>Mailchimp Transactional Setup Guide</summary>

1. A Mailchimp Transactional (Mandrill) account
2. API Key from Mailchimp Transactional
   - Log in to Mailchimp Transactional
   - Go to Account and locate "Extras" and click "API keys"
   - Create and copy a new Mandrill API key

[Learn how to get Mailchimp Transactional API Keys](https://mailchimp.com/developer/transactional/guides/quick-start/#generate-your-api-key).

</details>

<details>

<summary>Additional Configurations</summary>

1. `timePeriod`
   - Time period for performance analysis. Possible values:
     - `monthly` (default)
     - `quarterly`
     - `yearly`

2. `comparisonPeriod`
   - Type of comparison to perform. Possible values:
     - `MoM` - Month-over-Month (default)
     - `YoY` - Year-over-Year

3. `emailConfig.subjectTemplate`
   - Email subject line template
   - Supports placeholders: `{{month}}` and `{{year}}`
   - Default: `"Monthly Salesforce Performance Summary - {{month}} {{year}}"`

4. `emailConfig.fromName`
   - Email sender display name
   - Default: `"Salesforce Performance Report"`

5. `includePerRepBreakdown`
   - Include individual sales rep performance breakdown in the email
   - Default: `false`

</details>

<details>

<summary>Error Handling</summary>

The automation will fail and exit gracefully in the following cases:

1. **Invalid or Inaccessible Report ID**
   - If the report ID doesn't exist or you don't have permission to access it
   - Error message will indicate the report cannot be accessed

2. **No Metrics Found**
   - If the report executes successfully but contains no aggregated metrics
   - Prevents sending blank emails to recipients

3. **Authentication Failures**
   - If Salesforce or Mailchimp credentials are invalid
   - Check your configuration and ensure tokens haven't expired

</details>
