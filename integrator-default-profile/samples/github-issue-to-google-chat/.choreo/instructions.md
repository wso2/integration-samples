### What It Does

- Listens for issues with specific labels added in a specified GitHub repository via Webhooks
- Notifies a Google Chat space with the issue details including title, author, labels, and a link to the issue

<details>
<summary>GitHub Setup Guide</summary>

1. A GitHub account with access to the repositories you want to monitor

The following should be done after deploying the integration, and the endpoint URL is available.

1. Set up a webhook on the repository:
    - Go to your GitHub repository **Settings > Webhooks > Add webhook**
    - Set **Payload URL** to your deployed integration endpoint
    - Set **Content type** to `application/json`
    - Set a secret for security (make sure to add it to the integration configuration as well)
    - Under events select **Let me select individual events**
    - Check **Issues**
    - Click **Add webhook**

</details>

<details>

<summary>Google Chat Setup Guide</summary>

1. Navigate to a Google Chat space where you want to send messages
2. Click on the space name > **Apps & Integrations** > **Manage Webhooks**
3. Please note that only Google Workspace accounts can create webhooks
4. Click on **Add Webhook** and provide a name and optional avatar URL
5. In the given webhook URL, extract the following:
    - `spaceId`: The value after `/spaces/` and before `/messages`
    - `key`: The value of the `key` query parameter
    - `token`: The value of the `token` query parameter 
    - The webhook URL follows this structure: `https://chat.googleapis.com/v1/spaces/<spaceId>/messages?key=<key>&token=<token>`

</details>