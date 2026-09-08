import ballerinax/trigger.github;
import ballerina/regex;
import ballerina/time;

// Check if PR matches the configured filters
function shouldProcessPullRequest(github:PullRequest pr) returns boolean {
    // Filter by base branch (e.g., only main/release branches)
    if githubConfig.filterBaseBranches.length() > 0 {
        boolean matchesBaseBranch = githubConfig.filterBaseBranches.some(branch => pr.base.'ref == branch);
        if !matchesBaseBranch {
            return false;
        }
    }

    // Filter by label
    if githubConfig.filterLabels.length() > 0 {
        github:Label[] prLabels = pr.labels;
        boolean hasMatchingLabel = prLabels.some(
            prLabel => githubConfig.filterLabels.some(filterLabel => prLabel.name == filterLabel)
        );
        if !hasMatchingLabel {
            return false;
        }
    }

    // Filter by author
    if githubConfig.filterAuthor != "" {
        if pr.user.login != githubConfig.filterAuthor {
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
        // Parse ISO 8601 timestamps and calculate difference
        time:Utc|error createdTime = time:utcFromString(createdAt);
        time:Utc|error mergedTime = time:utcFromString(mergedAt);

        if createdTime is time:Utc && mergedTime is time:Utc {
            decimal diffSeconds = time:utcDiffSeconds(mergedTime, createdTime);
            decimal hours = diffSeconds / 3600.0;
            return hours;
        }
    }
    return ();
}

// Get target channel based on repo and branch routing rules
function getTargetChannel(github:Repository repo, string branch) returns string {
    string repoFullName = repo.full_name;

    // Check for repo/branch specific channel
    string repoBranchKey = string `${repoFullName}/${branch}`;
    string? repoBranchMatch = slackConfig.channelRouting.reduce(function(string? acc, string routing) returns string? {
        if acc != () {
            return acc;
        }
        string[] parts = regex:split(routing, ":");
        return (parts.length() == 2 && parts[0] == repoBranchKey) ? parts[1] : ();
    }, ());
    if repoBranchMatch is string {
        return repoBranchMatch;
    }

    // Check for repo-level channel
    string? repoMatch = slackConfig.channelRouting.reduce(function(string? acc, string routing) returns string? {
        if acc != () {
            return acc;
        }
        string[] parts = regex:split(routing, ":");
        return (parts.length() == 2 && parts[0] == repoFullName) ? parts[1] : ();
    }, ());
    if repoMatch is string {
        return repoMatch;
    }

    // Return default channel
    return slackConfig.channelId;
}

// Build Slack message from PR data
function buildSlackMessage(github:PullRequest pr, github:Repository repo) returns string {
    string message = "🎉 *Pull Request Merged Successfully!*\n\n";

    // Repository and PR info
    message += "*Repository:* <" + repo.html_url + "|" + repo.full_name + ">\n";
    message += "*Pull Request:* <" + pr.html_url + "|#" + pr.number.toString() + " - " + pr.title + ">\n";
    message += "*Author:* <" + pr.user.html_url + "|@" + pr.user.login + ">\n";
    message += "*Target Branch:* `" + pr.base.'ref + "`\n";

    message += "\n─────────────────────────\n\n";

    // Include PR description if configured
    if includePrDescription {
        string? prBody = pr.body;
        if prBody is string && prBody.trim() != "" {
            string description = prBody;
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
                message += "<" + reviewers[i].html_url + "|@" + reviewers[i].login + ">";
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
