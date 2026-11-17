import ballerina/http;

// Public, keyless APIs. Read-only lookups are safe to retry.
final readonly & http:RetryConfig readRetry = {count: 2, interval: 1, statusCodes: [429, 502, 503, 504]};

final http:Client geocodingClient = check new ("https://geocoding-api.open-meteo.com/v1",
    timeout = 15, retryConfig = readRetry);
final http:Client forecastClient = check new ("https://api.open-meteo.com/v1", timeout = 15, retryConfig = readRetry);
final http:Client archiveClient = check new ("https://archive-api.open-meteo.com/v1",
    timeout = 20, retryConfig = readRetry);
final http:Client advisoryClient = check new ("https://www.gov.uk/api/content", timeout = 20, retryConfig = readRetry);
