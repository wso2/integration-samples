import ballerina/http;

final readonly & map<string> duffelHeaders = {"Duffel-Version": "v2", "Accept": "application/json"};

final readonly & http:RetryConfig readRetry = {count: 2, interval: 1, statusCodes: [429, 502, 503, 504]};

// Searches and price checks may be retried.
final http:Client duffelSearchClient = check new (duffelBaseUrl,
    auth = {token: duffelAccessToken}, timeout = 60, retryConfig = readRetry);

// Orders, quotes and bookings change state at the supplier, so they are never retried
// automatically: a retried POST could double-book.
final http:Client duffelBookingClient = check new (duffelBaseUrl, auth = {token: duffelAccessToken}, timeout = 90);
