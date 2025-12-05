## What It Does

- When a new user signs up through an HTTP endpoint,
    - Creates a new Contact in Salesforce with the user's details
    - Sends a message to a Google Chat space notifying about the new signup

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. OAuth2 credentials:
  - Client ID (Consumer Key)
  - Client Secret (Consumer Secret)
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>

<summary>Google Chat Setup Guide</summary>

1. Navigate to a Google Chat space where you want to send messages
2. Click on the space name > Apps & Integrations > Manage Webhooks
3. Please note that only Google Workspace accounts can create webhooks
4. Click on "Add Webhook" and provide a name and optional avatar URL
5. In the given webhook URL, extract the following:
    - `spaceId`: The value after `/spaces/` and before `/messages`
    - `key`: The value of the `key` query parameter
    - `token`: The value of the `token` query parameter 
    - The webhook URL follows this structure: `https://chat.googleapis.com/v1/spaces/<spaceId>/messages?key=<key>&token=<token>`

</details>