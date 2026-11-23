import ballerina/http;

// GOV.UK Content API: public, keyless, and read-only, so lookups are safe to retry.
final http:Client advisoryClient = check new ("https://www.gov.uk/api/content", timeout = 20,
    retryConfig = {count: 2, interval: 1, statusCodes: [429, 502, 503, 504]});
