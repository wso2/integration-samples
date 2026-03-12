import ballerina/time;

# Formats a date string according to the configured date format
# + dateString - The input date string (RFC 3339 format from Shopify)
# + return - Formatted date string or original if formatting fails/not configured
function formatDate(string? dateString) returns string {
    if dateString is () {
        return "";
    }
    if dateFormat == "default" || dateString.trim() == "" {
        return dateString;
    }

    time:Civil|time:Error civilResult = time:civilFromString(dateString);
    if civilResult is time:Error {
        return dateString;
    }

    time:Civil civil = civilResult;

    if dateFormat == "iso8601" {
        string|time:Error formatted = time:civilToString(civil);
        if formatted is string {
            return formatted;
        }
    } else if dateFormat == "email" {
        string|time:Error formatted = time:civilToEmailString(civil, time:PREFER_ZONE_OFFSET);
        if formatted is string {
            return formatted;
        }
    }

    return dateString;
}
