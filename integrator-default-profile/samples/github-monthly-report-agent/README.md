# GitHub Monthly Report Agent

## Description

An AI agent that writes a monthly status report for a GitHub repository and emails it to your team as a PDF. Each run, it reads the repository's open issues and pull requests and writes a report with these sections:

- A summary and up to three recommended actions
- Open issues grouped by severity label
- Issues that nobody has acted on (no assignee and no comments), oldest first
- The pull requests that have been open the longest

It then converts the report to a PDF and sends it through Gmail, with the summary in the email body. This sample shows an agent that runs as an automation: it does one job from start to finish and then stops, so you can run it on a schedule, such as once a month.

## Prerequisites

- WSO2 Agent Builder, signed in, so that the default WSO2 model provider is configured.
- A GitHub token that can read the repository's issues and pull requests. For a public repository, a [fine-grained personal access token](https://github.com/settings/personal-access-tokens) with public repository read access is enough. For a private repository, give it **Issues: Read** and **Pull requests: Read** on that repository.
- A Gmail account, and a Google Cloud project with the Gmail API enabled. Follow the [setup guide of the Ballerina Gmail connector](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#setup-guide) to create an OAuth client and get a refresh token. When you authorize the Gmail APIs in the OAuth 2.0 Playground, include the `https://www.googleapis.com/auth/gmail.send` scope.

If your OAuth consent screen is in the **Testing** publishing status, Google expires the refresh token after seven days. Get a new token when that happens, or publish the app.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
githubToken = "<GITHUB_TOKEN>"
repoOwner = "<REPOSITORY_OWNER>"
repoName = "<REPOSITORY_NAME>"

gmailClientId = "<GMAIL_CLIENT_ID>"
gmailClientSecret = "<GMAIL_CLIENT_SECRET>"
gmailRefreshToken = "<GMAIL_REFRESH_TOKEN>"

recipientEmail = "<RECIPIENT_EMAIL>"
# Optional. Defaults to "Monthly GitHub report".
emailSubject = "Monthly GitHub report"

# Added when you run the integration while signed in to WSO2 Agent Builder.
[ballerina.ai.wso2ProviderConfig]
serviceUrl = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"
```

## Usage Instructions

1. Run the integration using the **Run** button. The agent fetches the open issues and pull requests, writes the report, and sends the email. When it finishes, the log shows `Monthly report sent` with the agent's summary, and the integration stops.
2. Open the inbox of `recipientEmail`. The email has the summary in its body and the report attached as `monthly-report.pdf`.
3. To get the report every month, deploy the integration and run it on a monthly schedule.

   > **Note:** The access token of the default WSO2 model provider expires one hour after it is issued. The **Run** button gets a new token each time it starts the integration. For a deployment that runs on a schedule, configure the agent to use a model provider with its own API key, such as OpenAI.

## How It Works

- The `main` function in `automation.bal` runs the agent once with the request `Generate and send this month's report.`, logs the result, and exits.
- The agent uses the default WSO2 model provider and these tools:
  - **fetchRepoItems**: Reads the 100 most recent open issues and 100 most recent open pull requests with the GitHub connector, and turns each into a flat row with its number, title, author, assignee, labels, comment count, creation date, age in days, and URL. It skips the pull requests that the GitHub issues API also returns, so each pull request appears once.
  - **convertToPdf**: Converts the agent's HTML report into an A4 PDF with the `ballerina/pdf` module, and writes it to a new temporary file, so a retry never overwrites an earlier report.
  - **emailReport**: Sends the PDF as an attachment named `monthly-report.pdf` to `recipientEmail` through the Gmail connector, with the summary as the plain-text body.
- The work is split so that each part does what it is reliable at. Code fetches the data, computes the age of each item, renders the PDF, and sends the email. The agent groups and ranks the items, picks the recommended actions, and writes the report.
- The instructions tell the agent to use only the rows that `fetchRepoItems` returns, and to treat issue and pull request titles as text to display, never as instructions to follow.
- The PDF renderer supports only simple HTML, so the instructions limit the report to headings, paragraphs, lists, and tables with minimal CSS, and tell the agent to list every item on its own line.

## Limitations

- The report covers at most the 100 most recent open issues and 100 most recent open pull requests. Older items are not included.
- The comment count is available only for issues. Pull request rows always have a comment count of `0`, and the instructions tell the agent not to use it for pull requests.
- Severity grouping uses the issue labels as they are. Label your issues by severity, such as `critical`, `high`, or `bug`, to get useful groups.
