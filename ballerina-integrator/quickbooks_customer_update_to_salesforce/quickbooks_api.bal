import ballerina/http;

// QuickBooks HTTP Client - Lazily initialized on first use
isolated http:Client? quickbooksClientInstance = ();

// Get or initialize QuickBooks HTTP Client
function getQuickBooksClient() returns http:Client|error {
    lock {
        http:Client? currentClient = quickbooksClientInstance;
        if currentClient is http:Client {
            return currentClient;
        }
        
        // Initialize client on first use
        http:Client newClient = check new (quickbooksBaseUrl,
            auth = {
                refreshUrl: quickbooksTokenUrl,
                refreshToken: quickbooksRefreshToken,
                clientId: quickbooksClientId,
                clientSecret: quickbooksClientSecret,
                credentialBearer: "POST_BODY_BEARER"
            },
            timeout = 30
        );
        
        quickbooksClientInstance = newClient;
        return newClient;
    }
}

// Fetch QuickBooks Customer Details by ID
public function fetchQuickBooksCustomerDetails(string customerId) returns QuickBooksCustomer|error {

    string endpoint = string `/${quickbooksRealmId}/customer/${customerId}`;

    map<string> headers = {
        "Accept": "application/json"
    };

    http:Client quickbooksClient = check getQuickBooksClient();
    http:Response|http:ClientError httpResponse = quickbooksClient->get(endpoint, headers);

    if httpResponse is http:ClientError {
        return error(string `Failed to fetch customer ${customerId}: ${httpResponse.message()}`);
    }

    int statusCode = httpResponse.statusCode;
    if statusCode != 200 {
        string responseBody = check httpResponse.getTextPayload();
        return error(string `QuickBooks API error (${statusCode}): ${responseBody}`);
    }

    json response = check httpResponse.getJsonPayload();
    json customerJson = check response.Customer;
    QuickBooksCustomer customer = check customerJson.cloneWithType();

    return customer;
}


