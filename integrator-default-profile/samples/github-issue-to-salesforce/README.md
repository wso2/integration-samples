# GitHub Issue to Salesforce Case Integration

## Description
This integration automatically creates a Salesforce Case when a GitHub issue 
is labeled with a specific trigger label. It maps the issue title to the case 
subject and the issue body to the case description, enabling seamless issue 
tracking between GitHub and Salesforce.

### What It Does
- Listens for GitHub issue labeled events via webhook from any repository
- Filters issues based on configurable trigger labels
- Creates a Salesforce Case with the following mapped fields:
  - Issue title → Case Subject
  - Issue body → Case Description
  - Configured status → Case Status
  - Configured priority → Case Priority
  - Configured owner → Case Owner
  - Configured type → Case Type
  - GitHub issue URL → GitHub_Issue_URL__c (custom field — see 
    Salesforce Custom Field Setup below)

### Salesforce Setup
1. A Salesforce account with API access
2. A Salesforce Connected App or External Client App with OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL (typically `https://login.salesforce.com/services/oauth2/token` for production or `https://test.salesforce.com/services/oauth2/token` for sandbox)
   - Base URL (your Salesforce instance URL)
3. The following custom fields on the Case object:
   - `GitHub_Issue_URL__c` (URL type) - Stores the GitHub issue URL

> **Note:** Connected Apps creation is restricted as of Salesforce Spring '26.
> Use External Client Apps instead.
> [Learn how to create an External Client App](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5)
> [Learn how to get OAuth2 credentials](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_web_server_flow.htm&type=5)

### Salesforce Custom Field Setup
1. Go to **Setup** > **Object Manager** > **Case**
2. Click **Fields & Relationships** > **New**
3. Select **URL** as the field type
4. Set Field Label as `GitHub Issue URL`
5. Ensure API Name (field name) is `GitHub_Issue_URL__c`
6. Click **Save**

## Configuration
The following configurations are required to run this integration.

### GitHub Configurations
- `triggerLabels` - List of labels that trigger case creation 
  (e.g., `["bug", "support"]`)

### Salesforce Credentials
- `salesforceBaseUrl` - Your Salesforce instance URL 
  (e.g., `https://your-instance.my.salesforce.com`)
- `salesforceClientId` - Your Salesforce Connected App/External Client App Client ID
- `salesforceClientSecret` - Your Salesforce Connected App/External Client App Client Secret
- `salesforceRefreshToken` - Your Salesforce OAuth refresh token
- `salesforceRefreshUrl` - Your Salesforce OAuth token endpoint 
  (e.g., `https://login.salesforce.com/services/oauth2/token` for production or 
  `https://test.salesforce.com/services/oauth2/token` for sandbox)

### Salesforce Case Defaults
- `caseStatus` - Default status for created cases (e.g., `"New"`)
- `casePriority` - Default priority for created cases 
  (e.g., `"Medium"`)
- `caseRecordType` - Default type for created cases 
  (e.g., `"User"`)
- `caseOwnerId` - Salesforce User ID or Queue ID to assign cases to

## Deploying on Devant
1. Sign in to your Devant account
2. Create a new Integration and follow instructions in 
   [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) 
   to import this repository
3. Select the **Technology** as `WSO2 Integrator: BI`
4. Choose the **Integration Type** as `Event Integration` and click **Create**
5. Once the build is successful, click **Configure to Continue** and set up 
   the required environment variables
6. Set up your GitHub webhook:
   - Go to your GitHub repository **Settings** > **Webhooks** > **Add webhook**
   - Set **Payload URL** to your Devant service URL
   - Set **Content type** to `application/json`
   - Under events select **"Let me select individual events"**
   - Check **Issues**
   - Click **Add webhook**
7. Once tested, promote the integration to production and set the relevant 
   environment variables in the production environment
