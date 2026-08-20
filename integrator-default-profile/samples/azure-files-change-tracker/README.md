# Azure Files Change Tracker

## Description

This integration reports what changed on an Azure Files share since it last ran. Each run lists the share, compares it against the snapshot saved by the previous run, logs a "file created", "file modified", or "file deleted" event for every difference, saves the new snapshot back to the share, and exits. Schedule it to turn the share into a periodic stream of change events without a continuously running process.

Azure Files keeps no change feed, so the tracker derives the events itself from each file's entity tag, the value Azure replaces on every write. The snapshot lives on the share, so every run continues from where the previous one stopped, wherever it executes.

## Prerequisites

1. An Azure storage account. In the [Azure portal](https://portal.azure.com), create a storage account for Azure Files, or use an existing one.
2. The account credentials. Open **Security + networking > Access keys** on the storage account and copy the storage account name and the key1 value.
3. A file share to watch. The tracker watches an existing share, so create one in the portal under **Data storage > File shares**, or with the Azure CLI:

```bash
az storage share create --name <share name> --account-name <storage account name> --account-key <storage account key>
```

## Configuration

Create a `Config.toml` file in the project directory with the following values:

- `accountName`: the storage account name
- `accountKey`: the storage account access key
- `shareName`: the name of the share to watch

```toml
accountName = "<storage account name>"
accountKey = "<storage account key>"
shareName = "<share name>"
```

## Usage Instructions

1. Run the integration locally using the Run button in Ballerina Integrator.

### Deploy on **WSO2 Cloud**

1. Deploy this integration on **WSO2 Cloud** as an **Automation**.
2. Click **Schedule** and configure how often the tracker should run.

Note: If scheduling this job is not a requirement, you can execute the integration locally using the Run button in Ballerina Integrator.

## How It Works

- Each run lists the share once with extended info, so every file arrives with its entity tag. No file content is downloaded, and the cost of a run scales with the number of files listed, not with the share's total size.
- The run compares the listing against the snapshot saved by the previous run: an unknown path is a creation, a changed entity tag is a modification, and a snapshot entry missing from the listing is a deletion.
- The three hooks in `functions.bal` (`onFileCreated`, `onFileModified`, `onFileDeleted`) log the events; replace them with whatever the change should trigger.
- The new snapshot is saved to `/.change-tracker-snapshot.json` on the share itself, so scheduled runs need no local state and deletions that happen between runs are still reported.
- The first run reports every file already on the share as created: there is no previous snapshot, so the first listing is the baseline.

## References

- [Schedule Your First Automation](https://wso2.com/devant/docs/quick-start-guides/schedule-your-first-automation)
