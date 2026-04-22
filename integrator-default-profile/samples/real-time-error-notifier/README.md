# Real-Time Error Notifier

## Description
This integration continuously monitors application logs in real time, detects critical errors, and instantly sends alerts to a designated Slack channel. By using a directory listener, it captures changes in log files and filters out critical errors. This integration is particularly useful for developers, DevOps engineers, and system administrators who need real-time visibility into critical application failures.

## Prerequisites
- Create a [Slack app](https://api.slack.com/quickstart#creating) and obtain a token for sending messages to a channel.
- Update the `slackChannel`, `slackToken` configurations with your Slack channel name and the token obtained.
- Provide the path to the log file you want to monitor in the `logFilePath` configuration. The default value is `./resources/logs` directory.

```
slackChannel = "error_notifications"
slackToken = "YOUR_SLACK_TOKEN"
directoryToListen = "./resources/logs"
```

## Usage Instructions
1. Configure `slackChannel`, `slackToken`, and `directoryToListen` before running the integration.
2. Run the integration locally using the **Run** button in Ballerina Integrator.
3. Once deployed, add new error logs to the specified directory to test the integration.

## How It Works
- This integration uses a directory listener to monitor log files in real time. 
- When a log file is modified, it checks if for critical errors by looking at the prefix of the error log. If the prefix is "ERROR:", the log message is considered a critical error. Logs with other prefixes ("INFO", "WARNING" etc.) are ignored. 
- The integration then sends a message to the specified Slack channel using the Slack API.
