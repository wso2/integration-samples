import ballerina/http;
import ballerina/log;
import ballerina/time;

// QuickBooks to Salesforce Sync Service
//
// SYNC LOGIC:
// CREATE (No Parent): Directly creates new account without search (fast path)
// CREATE (With Parent): Searches for parent by QuickBooks ID, creates with relationship
// UPDATE: Searches by QuickBooks ID, updates if found, skips if not found
// - Parent-child relationships are maintained automatically

// HTTP Listener for QuickBooks Webhooks
listener http:Listener webhookListener = check new (webhookPort);

// Startup logging
function init() {
    log:printInfo("###################################################################################################");
    log:printInfo("QUICKBOOKS TO SALESFORCE SYNC SERVICE STARTING");
    log:printInfo("###################################################################################################");
    log:printInfo(string `Webhook Port: ${webhookPort}`);
    log:printInfo(string `Webhook Endpoint: http://localhost:${webhookPort}/quickbooks/webhook`);
    log:printInfo(string `Health Check: http://localhost:${webhookPort}/quickbooks/health`);
    log:printInfo(string `Conflict Resolution: ${conflictResolution}`);
    log:printInfo(string `Filter Active Only: ${filterActiveOnly}`);
    log:printInfo(string `Create Contact: ${createContact}`);
    log:printInfo("###################################################################################################");
    log:printInfo("SERVICE READY - Waiting for webhooks...");
    log:printInfo("###################################################################################################");
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
        if verifyToken == webhookVerifyToken {
            log:printInfo("Webhook verification successful");
            return "Webhook verified successfully";
        }
        
        log:printError("Webhook verification failed - invalid token");
        return http:UNAUTHORIZED;
    }
    
    // Webhook event receiver (POST)
    resource function post webhook(http:Request request) returns http:Ok|http:InternalServerError {
        
        time:Utc currentTime = time:utcNow();
        string timestamp = time:utcToString(currentTime);
        log:printInfo(string `[${timestamp}] Webhook received from QuickBooks`);
        
        // Get payload with error handling
        json|error webhookPayload = request.getJsonPayload();
        
        if webhookPayload is error {
            log:printError(string `Failed to parse webhook payload: ${webhookPayload.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        // Process webhook event
        error? processResult = processQuickBooksWebhook(webhookPayload);
        
        if processResult is error {
            log:printError(string `Webhook processing failed: ${processResult.message()}`);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        log:printInfo("Webhook processed successfully. Ready for next request.");
        return http:OK;
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
