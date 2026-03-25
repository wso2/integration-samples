## What It Does
- Listens for GitHub issue labeled events via webhook
- Filters issues based on configurable trigger labels
- Supports monitoring multiple GitHub repositories simultaneously
- Creates a Salesforce Case with mapped fields from the GitHub issue
- Stores the GitHub issue URL in a custom Salesforce field (GitHub_Issue_URL__c)

<details>
<summary>GitHub Setup Guide</summary>

1. A GitHub account with access to the repositories you want to monitor

The following should be done after deploying the integration, and the endpoint URL is available.

1. Set up a webhook on the repository:
   - Go to your GitHub repository **Settings > Webhooks > Add webhook**
   - Set **Payload URL** to your deployed integration endpoint
   - Set **Content type** to `application/json`
   - Optionally set a secret for security (if you do, make sure to add it to the integration configuration as well)
   - Under events select **"Let me select individual events"**
   - Check **Issues**
   - Click **Add webhook**

</details>

<details>
<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

3. Create a custom field on the Salesforce Case object:
   - Go to **Setup → Object Manager → Case**
   - Click **Fields & Relationships → New**
   - Select **URL** as the field type
   - Set Field Label as `GitHub Issue URL`
   - Ensure API Name is `GitHub_Issue_URL__c`
   - Click **Save**
</details>

<details>
<summary>Additional Configurations</summary>

1. `triggerLabels`
   - List of GitHub issue labels that trigger Salesforce case creation
   - Example: `triggerLabels = ["bug", "support", "help wanted"]`

2. `githubRepositories`
   - List of GitHub repository URLs to monitor
   - Example: 
```
     githubRepositories = [
       "https://github.com/org/repo1",
       "https://github.com/org/repo2"
     ]
```

3. `caseStatus`
   - Default status for newly created Salesforce cases
   - Example: `"New"`

4. `casePriority`
   - Default priority for newly created Salesforce cases
   - Possible values: `"High"`, `"Medium"`, `"Low"`

5. `caseRecordType`
   - Default type for newly created Salesforce cases
   - Example: `"Mechanical"`

6. `caseOwnerId`
   - Salesforce User ID or Queue ID to assign cases to
   - User ID format: `005XXXXXXXXXXXXXXX`
   - Queue ID format: `00GXXXXXXXXXXXXXXX`

</details>