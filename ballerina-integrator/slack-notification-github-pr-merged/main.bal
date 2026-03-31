import ballerinax/trigger.github;
import ballerina/log;

// GitHub webhook service
service github:PullRequestService on githubListener {

    remote function onClosed(github:PullRequestEvent event) returns error? {

        // Check if this is a merged PR event using merged_at (more reliable than merged flag)
        string? mergedAt = event.pull_request.merged_at;
        if mergedAt is () || mergedAt == "" {
            log:printInfo("PR not merged, skipping notification");
            return;
        }

        // Apply filters
        if !shouldProcessPullRequest(event.pull_request) {
            log:printInfo("PR did not match filters, skipping notification");
            return;
        }

        // Build and send Slack message
        string slackMessage = buildSlackMessage(event.pull_request, event.repository);

        // Get target channel based on routing rules
        string targetChannel = getTargetChannel(event.repository, event.pull_request.base.'ref);

        _ = check slackClient->/chat\.postMessage.post({
            channel: targetChannel,
            text: slackMessage
        });

        log:printInfo(string `Slack notification sent for PR #${event.pull_request.number} to channel ${targetChannel}`);
    }

    remote function onOpened(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onReopened(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onAssigned(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onUnassigned(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onReviewRequested(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onReviewRequestRemoved(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onLabeled(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onUnlabeled(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }

    remote function onEdited(github:PullRequestEvent event) returns error? {
        // Not implemented - only handling merged PRs
    }
}
