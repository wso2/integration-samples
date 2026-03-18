import ballerinax/trigger.github;
import ballerina/regex;
import ballerina/time;
import ballerina/log;

// Escape Slack special characters to prevent injection/unwanted mentions
function escapeSlack(string input) returns string {
    string escaped = regex:replaceAll(input, "&", "&amp;");
    escaped = regex:replaceAll(escaped, "<", "&lt;");
    escaped = regex:replaceAll(escaped, ">", "&gt;");
    return escaped;
}

// Check if PR matches the configured filters
function shouldProcessPullRequest(github:PullRequest pr) returns boolean {
    // Filter by base branch (e.g., only main/release branches)
    if filterBaseBranches.length() > 0 {
        boolean matchesBaseBranch = false;
        foreach string branch in filterBaseBranches {
            if pr.base.'ref == branch {
                matchesBaseBranch = true;
                break;
            }
        }
        if !matchesBaseBranch {
            return false;
        }
    }

    // Filter by label
    if filterLabels.length() > 0 {
        boolean hasMatchingLabel = false;
        github:Label[]? prLabels = pr.labels;
        if prLabels is github:Label[] {
            foreach github:Label prLabel in prLabels {
                foreach string filterLabel in filterLabels {
                    if prLabel.name == filterLabel {
                        hasMatchingLabel = true;
                        break;
                    }
                }
                if hasMatchingLabel {
                    break;
                }
            }
        }
        if !hasMatchingLabel {
            return false;
        }
    }

    // Filter by author
    if filterAuthor != "" {
        if pr.user.login != filterAuthor {
            return false;
        }
    }

    return true;
}

// Calculate cycle time in hours
function calculateCycleTime(github:PullRequest pr) returns decimal? {
    string? createdAt = pr.created_at;
    string? mergedAt = pr.merged_at;

    if createdAt is string && mergedAt is string {
        time:Utc|error createdTime = time:utcFromString(createdAt);
        time:Utc|error mergedTime = time:utcFromString(mergedAt);

        if createdTime is error {
            log:printWarn(string `Failed to parse PR created_at timestamp: ${createdAt}`, 'error = createdTime);
            return ();
        }
        if mergedTime is error {
            log:printWarn(string `Failed to parse PR merged_at timestamp: ${mergedAt}`, 'error = mergedTime);
            return ();
        }

        decimal diffSeconds = time:utcDiffSeconds(mergedTime, createdTime);
        decimal hours = diffSeconds / 3600.0;
        return hours;
    }
    return ();
}

// Get target channel based on repo and branch routing rules
// Single-pass: prefers repo/branch match, falls back to repo-level match
function getTargetChannel(github:Repository repo, string branch) returns string {
    string repoFullName = repo.full_name;
    string repoBranchKey = string `${repoFullName}/${branch}`;
    string repoLevelChannel = "";

    foreach string routing in channelRouting {
        string[] parts = regex:split(routing, ":");
        if parts.length() == 2 {
            string key = parts[0];
            string channel = parts[1];
            // Highest precedence: exact repo/branch match
            if key == repoBranchKey {
                return channel;
            }
            // Fallback: repo-level match (kept if no repo/branch match found)
            if key == repoFullName {
                repoLevelChannel = channel;
            }
        }
    }

    if repoLevelChannel != "" {
        return repoLevelChannel;
    }

    // Return default channel
    return slackChannelId;
}

// Build Slack message from PR data
function buildSlackMessage(github:PullRequest pr, github:Repository repo) returns string {
    // Escape untrusted fields before embedding into Slack markup
    string safeTitle = escapeSlack(pr.title);
    string safeLogin = escapeSlack(pr.user.login);
    string safeRepoFullName = escapeSlack(repo.full_name);

    string message = "🎉 *Pull Request Merged Successfully!*\n\n";

    // Repository and PR info
    message += "*Repository:* <" + repo.html_url + "|" + safeRepoFullName + ">\n";
    message += "*Pull Request:* <" + pr.html_url + "|#" + pr.number.toString() + " - " + safeTitle + ">\n";
    message += "*Author:* <" + pr.user.html_url + "|@" + safeLogin + ">\n";
    message += "*Target Branch:* `" + pr.base.'ref + "`\n";

    message += "\n─────────────────────────\n\n";

    // Include PR description if configured
    if includePrDescription {
        string? prBody = pr.body;
        if prBody is string && prBody.trim() != "" {
            string description = escapeSlack(prBody);
            if description.length() > 200 {
                description = description.substring(0, 200) + "...";
            }
            message += "*Description:*\n" + description + "\n\n";
        }
    }

    // Include reviewers if configured
    if includeReviewers {
        github:User[]? reviewers = pr.requested_reviewers;
        if reviewers is github:User[] && reviewers.length() > 0 {
            message += "*Reviewers:* ";
            foreach int i in 0 ..< reviewers.length() {
                string safeReviewerLogin = escapeSlack(reviewers[i].login);
                message += "<" + reviewers[i].html_url + "|@" + safeReviewerLogin + ">";
                if i < reviewers.length() - 1 {
                    message += ", ";
                }
            }
            message += "\n\n";
        }
    }

    // Include diff stats if configured
    if includeDiffStats {
        int additions = pr.additions ?: 0;
        int deletions = pr.deletions ?: 0;
        int changedFiles = pr.changed_files ?: 0;
        message += "*Code Changes:*\n";
        message += "   • Files changed: " + changedFiles.toString() + "\n";
        message += "   • Additions: +" + additions.toString() + " lines\n";
        message += "   • Deletions: -" + deletions.toString() + " lines\n\n";
    }

    // Include cycle time if configured
    if includeCycleTime {
        decimal? cycleTime = calculateCycleTime(pr);
        if cycleTime is decimal {
            string formattedTime = formatCycleTime(cycleTime);
            message += "*Cycle Time:* " + formattedTime + "\n\n";
        }
    }

    message += "✅ *Status:* Merged and ready to deploy!";

    return message;
}

// Format cycle time in a human-readable format
function formatCycleTime(decimal hours) returns string {
    if hours < 1d {
        int minutes = <int>(hours * 60);
        return minutes.toString() + " minute(s)";
    } else if hours < 24d {
        decimal roundedHours = decimal:round(hours, 1);
        return roundedHours.toString() + " hour(s)";
    } else {
        decimal days = hours / 24d;
        decimal roundedDays = decimal:round(days, 1);
        return roundedDays.toString() + " day(s)";
    }
}
