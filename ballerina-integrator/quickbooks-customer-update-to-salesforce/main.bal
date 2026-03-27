import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/crypto;

// QuickBooks to Salesforce Sync Service
//
// SYNC LOGIC:
// CREATE (No Parent): Directly creates new account without search (fast path)
// CREATE (With Parent): Searches for parent by QuickBooks ID, creates with relationship
// UPDATE: Searches by QuickBooks ID, updates if found, skips if not found
// - Parent-child relationships are maintained automatically

// HTTP Listener for QuickBooks Webhooks
listener http:Listener webhookListener = check new (webhookConfig.port);

// Startup logging
function init() {
    log:printInfo("###################################################################################################");
    log:printInfo("QUICKBOOKS TO SALESFORCE SYNC SERVICE STARTING");
    log:printInfo("###################################################################################################");
    log:printInfo(string `Webhook Port: ${webhookConfig.port}`);
    log:printInfo(string `Webhook Endpoint: http://localhost:${webhookConfig.port}/quickbooks/webhook`);
    log:printInfo(string `Health Check: http://localhost:${webhookConfig.port}/quickbooks/health`);
    log:printInfo(string `Conflict Resolution: ${syncConfig.conflictResolution}`);
    log:printInfo(string `Filter Active Only: ${syncConfig.filterActiveOnly}`);
    log:printInfo("###################################################################################################");
    log:printInfo("SERVICE READY - Waiting for webhooks...");
    log:printInfo("###################################################################################################");
}

// Compute HMAC-SHA256 signature for webhook validation
function computeHmacSignature(byte[] payload, string secretKey) returns byte[]|error {
    byte[] keyBytes = secretKey.toBytes();
    byte[] hmacSignature = check crypto:hmacSha256(payload, keyBytes);
    return hmacSignature;
}

// Root Service for default path
service / on webhookListener {
    
    // Root health check
    resource function get .() returns json {
        time:Utc currentTime = time:utcNow();
        return {
            status: "UP",
            serviceName: "QuickBooks to Salesforce Sync",
            timestamp: currentTime,
            endpoints: {
                health: "/quickbooks/health",
                webhook: "/quickbooks/webhook"
            }
        };
    }
}

// QuickBooks Webhook Service
service /quickbooks on webhookListener {
    
    // Health check endpoint
    resource function get health() returns json {
        time:Utc currentTime = time:utcNow();
        return {
            status: "UP",
            serviceName: "QuickBooks to Salesforce Sync",
            timestamp: currentTime
        };
    }
    
    // Webhook verification endpoint (GET)
    resource function get webhook(@http:Query string verifyToken) returns string|http:Unauthorized {
        if verifyToken == webhookConfig.verifyToken {
            log:printInfo("Webhook verification successful");
            return "Webhook verified successfully";
        }
        
        log:printError("Webhook verification failed - invalid token");
        return http:UNAUTHORIZED;
    }
    
    // Webhook event receiver (POST)
    resource function post webhook(http:Request request) returns http:Ok|http:InternalServerError|http:Unauthorized {
        
        time:Utc currentTime = time:utcNow();
        string timestamp = time:utcToString(currentTime);
        log:printInfo(string `[${timestamp}] Webhook received from QuickBooks`);
        
        // Extract raw request body for signature validation
        byte[]|http:ClientError rawPayload = request.getBinaryPayload();
        
        if rawPayload is http:ClientError {
            log:printError(string `Failed to read request body: ${rawPayload.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        // Validate HMAC-SHA256 signature
        string|http:HeaderNotFoundError intuitSignatureHeader = request.getHeader("intuit-signature");
        
        if intuitSignatureHeader is http:HeaderNotFoundError {
            log:printError("Webhook signature validation failed: intuit-signature header missing");
            return http:UNAUTHORIZED;
        }
        
        string intuitSignature = intuitSignatureHeader;
        
        // Compute HMAC-SHA256 using webhook verify token as key
        byte[]|error computedHmac = computeHmacSignature(rawPayload, webhookConfig.verifyToken);
        
        if computedHmac is error {
            log:printError(string `Failed to compute HMAC signature: ${computedHmac.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        // Base64 encode the computed signature
        string computedSignature = computedHmac.toBase64();
        
        // Compare signatures
        if intuitSignature != computedSignature {
            log:printError("Webhook signature validation failed: signatures do not match");
            log:printError(string `Expected: ${computedSignature}, Received: ${intuitSignature}`);
            return http:UNAUTHORIZED;
        }
        
        log:printInfo("Webhook signature validated successfully");
        
        // Parse JSON payload
        string|error payloadString = string:fromBytes(rawPayload);
        
        if payloadString is error {
            log:printError(string `Failed to convert payload to string: ${payloadString.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        json|error webhookPayload = payloadString.fromJsonString();
        
        if webhookPayload is error {
            log:printError(string `Failed to parse webhook payload: ${webhookPayload.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        // Process webhook asynchronously - return immediately after validation
        log:printInfo("Webhook validated - processing asynchronously");
        
        // Start background processing using detached worker
        future<()> asyncProcessing = start processWebhookAsync(webhookPayload);
        
        // Return immediately without waiting for processing to complete
        return http:OK;
    }
}

// Process webhook asynchronously in background
function processWebhookAsync(json webhookPayload) {
    log:printInfo("Starting asynchronous webhook processing");
    
    error? processResult = processQuickBooksWebhook(webhookPayload);
    
    if processResult is error {
        log:printError(string `Webhook processing failed: ${processResult.message()}`);
    } else {
        log:printInfo("Webhook processed successfully. Ready for next request.");
    }
}

// Process QuickBooks Webhook Event
function processQuickBooksWebhook(json webhookPayload) returns error? {
    
    // Check if eventNotifications field exists
    json|error eventNotificationsResult = webhookPayload.eventNotifications;
    if eventNotificationsResult is error {
        log:printError(string `Invalid webhook payload: ${eventNotificationsResult.message()}`);
        return eventNotificationsResult;
    }
    
    json eventNotificationsJson = eventNotificationsResult;
    json[] eventNotifications = [];
    
    if eventNotificationsJson is json[] {
        eventNotifications = eventNotificationsJson;
    } else {
        eventNotifications = [eventNotificationsJson];
    }
    
    foreach json notification in eventNotifications {
        // Validate realm ID to ensure webhook is for the correct QuickBooks tenant
        json|error realmIdResult = notification.realmId;
        
        if realmIdResult is error {
            log:printError(string `Notification missing realmId field: ${realmIdResult.message()}`);
            continue;
        }
        
        // Extract realm ID as string
        string notificationRealmId = "";
        if realmIdResult is string {
            notificationRealmId = realmIdResult;
        } else {
            log:printError(string `Notification realmId is not a string: ${realmIdResult.toString()}`);
            continue;
        }
        
        // Compare with configured realm ID
        if notificationRealmId != quickbooksConfig.realmId {
            log:printError(string `Rejecting notification for incorrect tenant - Expected realm ID: ${quickbooksConfig.realmId}, Received: ${notificationRealmId}`);
            continue;
        }
        
        log:printInfo(string `Realm ID validated: ${notificationRealmId}`);
        
        json dataChangeEventJson = check notification.dataChangeEvent;
        json[] dataChangeEvents = [];
        
        if dataChangeEventJson is json[] {
            dataChangeEvents = dataChangeEventJson;
        } else {
            dataChangeEvents = [dataChangeEventJson];
        }
        
        foreach json changeEvent in dataChangeEvents {
            json entitiesJson = check changeEvent.entities;
            json[] entities = [];
            
            if entitiesJson is json[] {
                entities = entitiesJson;
            } else {
                entities = [entitiesJson];
            }
            
            foreach json entity in entities {
                string entityName = check entity.name;
                string entityId = check entity.id;
                string operation = check entity.operation;
                
                // Process only Customer entities
                if entityName == "Customer" && (operation == "Create" || operation == "Update") {
                    log:printInfo(string `Processing ${operation} for Customer ID: ${entityId}`);
                    
                    QuickBooksCustomer|error qbCustomerResult = fetchQuickBooksCustomerDetails(entityId);
                    
                    if qbCustomerResult is error {
                        log:printError(string `Failed to fetch customer ${entityId}: ${qbCustomerResult.message()}`);
                        continue;
                    }
                    
                    QuickBooksCustomer qbCustomer = qbCustomerResult;
                    
                    SyncResult result = syncCustomerToSalesforce(qbCustomer, operation);
                    
                    if result.success {
                        string? accountId = result?.accountId;
                        if accountId is string {
                            log:printInfo(string `Sync successful: ${qbCustomer.DisplayName} -> Salesforce Account ${accountId}`);
                        } else {
                            log:printInfo(string `Sync completed: ${qbCustomer.DisplayName}`);
                        }
                    } else {
                        string? errorDetails = result?.errorDetails;
                        if errorDetails is string {
                            log:printError(string `Sync failed for ${qbCustomer.DisplayName}: ${errorDetails}`);
                        } else {
                            log:printError(string `Sync failed for ${qbCustomer.DisplayName}`);
                        }
                    }
                }
            }
        }
    }
}
