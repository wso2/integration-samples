# Daily Email Notifier

## Description

A scheduled task that sends a daily email update at 8 AM using the Gmail API. This sample demonstrates how to integrate
Ballerina with an external email service.

## Prerequisites

- Obtain the following Gmail API credentials by following the steps in the [Gmail API documentation](https://developers.google.com/gmail/api/guides):
    - Client ID
    - Client Secret
    - Refresh Token

## Usage Instructions

1. Make sure to configure Gmail API credentials (`clientId`, `clientSecret`, and `refreshToken`) in the `Config.toml` file.
2. Also set up `senderEmail`, `receiverEmail`, and `gmailUserId` values in the `Config.toml` file.
3. Run the Ballerina application to send an email update.

### Deploy on **Devant**

1. Deploy this integration on **Devant** as an **Automation**.
2. Configure the Gmail API credentials (`clientId`, `clientSecret`, and `refreshToken`), `senderEmail`, `receiverEmail`, and `gmailUserId` before running the **Automation**.
2. Once deployed, it will send the email every day at 8 AM.

## How It Works

- The application constructs an email message with a subject and body.
- It sends the email using the [Gmail connector](https://central.ballerina.io/ballerinax/googleapis.gmail/latest).
- If successful, it logs the email ID; otherwise, it logs an error message.

## Example Log Output

```
INFO  [ballerina] Sending email to: example@domain.com
INFO  [ballerina] Email sent successfully: Email ID = 12345xyz
```

## References

- [Schedule Your First Automation](https://wso2.com/devant/docs/quick-start-guides/schedule-your-first-automation)
