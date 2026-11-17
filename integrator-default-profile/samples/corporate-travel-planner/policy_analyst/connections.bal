import ballerina/http;

// Frankfurter: European Central Bank reference rates, no API key needed.
final http:Client fxClient = check new ("https://api.frankfurter.dev/v1", timeout = 15,
    retryConfig = {count: 2, interval: 1, statusCodes: [429, 502, 503, 504]});
