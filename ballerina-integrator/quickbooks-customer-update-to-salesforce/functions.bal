import ballerinax/salesforce;
import ballerina/log;
import ballerina/time;
import ballerina/lang.regexp;

// Check if customer should be synced based on filters
public isolated function shouldSyncCustomer(QuickBooksCustomer qbCustomer) returns boolean {
    
    // Filter by active status if configured
    if syncConfig.filterActiveOnly {
        boolean? active = qbCustomer?.Active;
        if active is boolean && !active {
            return false;
        }
    }
    
    return true;
}

// Find Salesforce Account by QuickBooks ID
public isolated function findAccountByQuickBooksId(string quickbooksId) returns string?|error {
    // quickbooksId will be valided by salesforce for type so need to validate here. soql injection is not possible through quickbooksId.
    string soqlQuery = string `SELECT Id FROM Account WHERE QuickbooksSync__c = '${quickbooksId}' LIMIT 1`;
    
    stream<record {}, error?> resultStream = check salesforceClient->query(soqlQuery);
    
    record {|record {} value;|}? result = check resultStream.next();
    check resultStream.close();
    
    if result is record {|record {} value;|} {
        record {} accountRecord = result.value;
        anydata idValue = accountRecord["Id"];
        if idValue is string {
            return idValue;
        }
    }
    
    return ();
}



// Resolve conflict based on strategy
public isolated function shouldUpdateAccount(SalesforceAccount existingAccount, QuickBooksCustomer qbCustomer) returns boolean|error {
    
    if syncConfig.conflictResolution == SOURCE_WINS {
        return true;
    } else if syncConfig.conflictResolution == DESTINATION_WINS {
        return false;
    } else if syncConfig.conflictResolution == MOST_RECENT {
        // Compare last modified dates
        string? sfLastModified = existingAccount?.LastModifiedDate;
        MetaData? qbMetadata = qbCustomer?.MetaData;
        
        if sfLastModified is () || qbMetadata is () {
            return true;
        }
        
        string? qbLastUpdated = qbMetadata?.LastUpdatedTime;
        if qbLastUpdated is () {
            return true;
        }
        
        // Parse Salesforce date and compare
        time:Utc sfTime = check time:utcFromString(sfLastModified);
        time:Utc qbTime = check time:utcFromString(qbLastUpdated);
        
        return time:utcDiffSeconds(qbTime, sfTime) > 0.0d;
    }
    
    return true;
}

// Sync QuickBooks Customer to Salesforce
public function syncCustomerToSalesforce(QuickBooksCustomer qbCustomer, string operation) returns SyncResult {
    
    // Check if customer should be synced
    if !shouldSyncCustomer(qbCustomer) {
        return {
            success: false,
            message: "Customer filtered out based on sync criteria"
        };
    }
    
    // Map QuickBooks customer to Salesforce account
    SalesforceAccount sfAccount = mapQuickBooksCustomerToSalesforceAccount(qbCustomer);
    
    // Handle parent account relationship for sub-customers
    // Only process parent relationship for Create operations
    if operation == "Create" {
        ParentRef? parentRef = qbCustomer?.ParentRef;
        
        if parentRef is ParentRef {
            string? parentCustomerId = parentRef?.value;
            
            if parentCustomerId is string {
                // Search Salesforce for parent account by QuickBooks ID
                string?|error parentAccountIdResult = findAccountByQuickBooksId(parentCustomerId);
                
                if parentAccountIdResult is string {
                    // Parent found in Salesforce
                    sfAccount.ParentId = parentAccountIdResult;
                    log:printInfo(string `Found parent account ${parentAccountIdResult} for QuickBooks parent ID ${parentCustomerId}`);
                } else if parentAccountIdResult is error {
                    // Check if error is due to missing custom field
                    // In this scenario, bad request possible mostly due to missing custom field so got to falls back, if the fallsback fail error handling will handle it., 
                    string errorMessage = parentAccountIdResult.message();
                    string:RegExp quickbooksSyncPattern = re `QuickbooksSync__c`;
                    string:RegExp noColumnPattern = re `No such column`;
                    string:RegExp badRequestPattern = re `Bad Request`;
                    
                    boolean hasQuickbooksSyncError = quickbooksSyncPattern.find(errorMessage) is regexp:Span;
                    boolean hasNoColumnError = noColumnPattern.find(errorMessage) is regexp:Span;
                    boolean hasBadRequestError = badRequestPattern.find(errorMessage) is regexp:Span;
                    
                    if hasQuickbooksSyncError || hasNoColumnError || hasBadRequestError {
                        log:printError("Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object");
                        log:printError(string `Error finding parent account with QuickBooks ID ${parentCustomerId}: ${errorMessage}`);
                        // Stop sync process - parent hierarchy requires custom field
                        return {
                            success: false,
                            message: "Cannot sync customer with parent - QuickbooksSync__c custom field missing",
                            errorDetails: "Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object"
                        };
                    } else {
                        log:printError(string `Error finding parent account with QuickBooks ID ${parentCustomerId}: ${errorMessage}`);
                    }
                } else {
                    // Parent does not exist in Salesforce - create it first (recursive)
                    log:printInfo(string `Parent account not found in Salesforce for QuickBooks ID ${parentCustomerId}, fetching from QuickBooks...`);
                    QuickBooksCustomer|error parentCustomerResult = fetchQuickBooksCustomerDetails(parentCustomerId);
                    
                    if parentCustomerResult is error {
                        log:printError(string `Failed to fetch parent customer ${parentCustomerId}: ${parentCustomerResult.message()}`);
                        return {
                            success: false,
                            message: string `Cannot sync customer with parent - failed to fetch parent customer ${parentCustomerId}`,
                            errorDetails: parentCustomerResult.message()
                        };
                    }
                    
                    QuickBooksCustomer parentCustomer = parentCustomerResult;
                    SyncResult parentSyncResult = syncCustomerToSalesforce(parentCustomer, "Create");
                    
                    if !parentSyncResult.success {
                        log:printError(string `Failed to sync parent customer ${parentCustomerId}`);
                        string? parentErrorDetails = parentSyncResult?.errorDetails;
                        return {
                            success: false,
                            message: string `Cannot sync customer with parent - failed to sync parent customer ${parentCustomerId}`,
                            errorDetails: parentErrorDetails ?: "Parent sync failed without error details"
                        };
                    }
                    
                    string? createdParentId = parentSyncResult?.accountId;
                    if createdParentId is string {
                        sfAccount.ParentId = createdParentId;
                        log:printInfo(string `Created parent account ${createdParentId} for QuickBooks parent ID ${parentCustomerId}`);
                    } else {
                        log:printError(string `Parent sync succeeded but no account ID returned for ${parentCustomerId}`);
                        return {
                            success: false,
                            message: "Cannot sync customer with parent - parent sync succeeded but no account ID returned",
                            errorDetails: "Parent account ID missing after successful sync"
                        };
                    }
                }
            }
        } else {
            // No parent reference - this is a top-level customer
            sfAccount.ParentId = ();
        }
    } else {
        // For Update operations, handle parent relationship separately if needed
        ParentRef? parentRef = qbCustomer?.ParentRef;
        
        if parentRef is ParentRef {
            string? parentCustomerId = parentRef?.value;
            
            if parentCustomerId is string {
                // Search for parent account
                string?|error parentAccountIdResult = findAccountByQuickBooksId(parentCustomerId);
                
                if parentAccountIdResult is string {
                    sfAccount.ParentId = parentAccountIdResult;
                } else if parentAccountIdResult is error {
                    // Check if error is due to missing custom field
                    string errorMessage = parentAccountIdResult.message();
                    string:RegExp quickbooksSyncPattern = re `QuickbooksSync__c`;
                    string:RegExp noColumnPattern = re `No such column`;
                    string:RegExp badRequestPattern = re `Bad Request`;
                    
                    boolean hasQuickbooksSyncError = quickbooksSyncPattern.find(errorMessage) is regexp:Span;
                    boolean hasNoColumnError = noColumnPattern.find(errorMessage) is regexp:Span;
                    boolean hasBadRequestError = badRequestPattern.find(errorMessage) is regexp:Span;
                    
                    if hasQuickbooksSyncError || hasNoColumnError || hasBadRequestError {
                        log:printError("Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object");
                        log:printError(string `Error finding parent account with QuickBooks ID ${parentCustomerId}: ${errorMessage}`);
                    } else {
                        log:printError(string `Error finding parent account with QuickBooks ID ${parentCustomerId}: ${errorMessage}`);
                    }
                } else {
                    // Parent not found during update - fetch and create
                    QuickBooksCustomer|error parentCustomerResult = fetchQuickBooksCustomerDetails(parentCustomerId);
                    
                    if parentCustomerResult is error {
                        log:printError(string `Failed to fetch parent customer ${parentCustomerId}: ${parentCustomerResult.message()}`);
                        return {
                            success: false,
                            message: string `Cannot update customer with parent - failed to fetch parent customer ${parentCustomerId}`,
                            errorDetails: parentCustomerResult.message()
                        };
                    }
                    
                    QuickBooksCustomer parentCustomer = parentCustomerResult;
                    SyncResult parentSyncResult = syncCustomerToSalesforce(parentCustomer, "Create");
                    
                    if !parentSyncResult.success {
                        log:printError(string `Failed to sync parent customer ${parentCustomerId}`);
                        string? parentErrorDetails = parentSyncResult?.errorDetails;
                        return {
                            success: false,
                            message: string `Cannot update customer with parent - failed to sync parent customer ${parentCustomerId}`,
                            errorDetails: parentErrorDetails ?: "Parent sync failed without error details"
                        };
                    }
                    
                    string? createdParentId = parentSyncResult?.accountId;
                    if createdParentId is string {
                        sfAccount.ParentId = createdParentId;
                        log:printInfo(string `Created parent account ${createdParentId} for QuickBooks parent ID ${parentCustomerId}`);
                    } else {
                        log:printError(string `Parent sync succeeded but no account ID returned for ${parentCustomerId}`);
                        return {
                            success: false,
                            message: "Cannot update customer with parent - parent sync succeeded but no account ID returned",
                            errorDetails: "Parent account ID missing after successful sync"
                        };
                    }
                }
            }
        } else {
            sfAccount.ParentId = ();
        }
    }
    
    string? accountId = ();
    
    // Handle Update operation - search by QuickBooks ID
    if operation == "Update" {
        string?|error existingAccountIdResult = findAccountByQuickBooksId(qbCustomer.Id);
        
        if existingAccountIdResult is error {
            // Check if error is due to missing custom field
            string errorMessage = existingAccountIdResult.message();
            string:RegExp quickbooksSyncPattern = re `QuickbooksSync__c`;
            string:RegExp noColumnPattern = re `No such column`;
            string:RegExp badRequestPattern = re `Bad Request`;
            
            boolean hasQuickbooksSyncError = quickbooksSyncPattern.find(errorMessage) is regexp:Span;
            boolean hasNoColumnError = noColumnPattern.find(errorMessage) is regexp:Span;
            boolean hasBadRequestError = badRequestPattern.find(errorMessage) is regexp:Span;
            
            if hasQuickbooksSyncError || hasNoColumnError || hasBadRequestError {
                // Stop update operation - custom field is required
                log:printError("Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object");
                log:printError(string `Cannot update customer ${qbCustomer.DisplayName} - QuickbooksSync__c field is required for update operations`);
                return {
                    success: false,
                    message: "Cannot update - QuickbooksSync__c custom field missing",
                    errorDetails: "Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object"
                };
            }
            
            return {
                success: false,
                message: "Error finding existing account",
                errorDetails: existingAccountIdResult.message()
            };
        }
        
        if existingAccountIdResult is string {
            // Account exists - update it
            string existingAccountId = existingAccountIdResult;
            
            string queryStr = string `SELECT Id, Name, LastModifiedDate FROM Account WHERE Id = '${existingAccountId}' LIMIT 1`;
            stream<record {}, error?>|error accountStreamResult = salesforceClient->query(queryStr);
            
            if accountStreamResult is error {
                return {
                    success: false,
                    message: "Error querying account",
                    errorDetails: accountStreamResult.message()
                };
            }
            
            stream<record {}, error?> accountStream = accountStreamResult;
            record {|record {} value;|}|error? accountResult = accountStream.next();
            error? closeResult = accountStream.close();
            
            if accountResult is error {
                return {
                    success: false,
                    message: "Error reading account",
                    errorDetails: accountResult.message()
                };
            }
            
            if accountResult is () {
                return {
                    success: false,
                    message: "Account not found"
                };
            }
            
            record {} existingAccountRecord = accountResult.value;
            SalesforceAccount|error existingAccountResult = existingAccountRecord.cloneWithType(SalesforceAccount);
            if existingAccountResult is error {
                return {
                    success: false,
                    message: "Error converting account record",
                    errorDetails: existingAccountResult.message()
                };
            }
            
            SalesforceAccount existingAccount = existingAccountResult;
            boolean|error shouldUpdate = shouldUpdateAccount(existingAccount, qbCustomer);
            
            if shouldUpdate is error {
                return {
                    success: false,
                    message: "Error in conflict resolution",
                    errorDetails: shouldUpdate.message()
                };
            }
            
            if shouldUpdate {
                error? updateResult = salesforceClient->update("Account", existingAccountId, sfAccount);
                
                if updateResult is error {
                    return {
                        success: false,
                        message: "Error updating Salesforce account",
                        errorDetails: updateResult.message()
                    };
                }
                
                accountId = existingAccountId;
                log:printInfo(string `Updated existing account ${existingAccountId} for QuickBooks customer ${qbCustomer.Id}`);
            } else {
                accountId = existingAccountId;
                log:printInfo(string `Skipped update for account ${existingAccountId} due to conflict resolution`);
            }
        } else {
            // Account not found in Salesforce - fall back to create operation
            log:printWarn(string `User not found in Salesforce for QuickBooks ID: ${qbCustomer.Id}`);
            log:printInfo(string `Falling back to Create operation for customer: ${qbCustomer.DisplayName}`);
            
            // Recursively call with Create operation
            return syncCustomerToSalesforce(qbCustomer, "Create");
        }
    } else {
        // Create operation - check for existing account first (idempotent)
        log:printInfo(string `Checking for existing account with QuickBooks ID: ${qbCustomer.Id}`);
        
        // Check if account already exists
        string?|error existingAccountCheckResult = findAccountByQuickBooksId(qbCustomer.Id);
        
        if existingAccountCheckResult is string {
            // Account already exists - return existing ID
            string existingAccountId = existingAccountCheckResult;
            accountId = existingAccountId;
            log:printInfo(string `Account already exists with ID ${existingAccountId} for QuickBooks customer ${qbCustomer.Id} - returning existing account (idempotent)`);
            
            return {
                success: true,
                accountId: accountId,
                message: "Account already exists - returned existing account ID"
            };
        } else if existingAccountCheckResult is error {
            // Check if error is due to missing custom field or actual query error
            string errorMessage = existingAccountCheckResult.message();
            string:RegExp quickbooksSyncPattern = re `QuickbooksSync__c`;
            string:RegExp noColumnPattern = re `No such column`;
            string:RegExp badRequestPattern = re `Bad Request`;
            
            boolean hasQuickbooksSyncError = quickbooksSyncPattern.find(errorMessage) is regexp:Span;
            boolean hasNoColumnError = noColumnPattern.find(errorMessage) is regexp:Span;
            boolean hasBadRequestError = badRequestPattern.find(errorMessage) is regexp:Span;
            
            if !(hasQuickbooksSyncError || hasNoColumnError || hasBadRequestError) {
                // Real error - not just missing field
                return {
                    success: false,
                    message: "Error checking for existing account",
                    errorDetails: errorMessage
                };
            }
            
            // Missing custom field - will handle during create attempt
            log:printInfo("QuickbooksSync__c field not available - proceeding with create");
        } else {
            // No existing account found - proceed with create
            log:printInfo(string `No existing account found for QuickBooks ID ${qbCustomer.Id} - proceeding with create`);
        }
        
        // Proceed with account creation
        salesforce:CreationResponse|error createResult = salesforceClient->create("Account", sfAccount);
        
        if createResult is error {
            // Check if error is due to missing QuickbooksSync__c field
            string errorMessage = createResult.message();
            string:RegExp quickbooksSyncPattern = re `QuickbooksSync__c`;
            string:RegExp noColumnPattern = re `No such column`;
            string:RegExp badRequestPattern = re `Bad Request`;
            
            boolean hasQuickbooksSyncError = quickbooksSyncPattern.find(errorMessage) is regexp:Span;
            boolean hasNoColumnError = noColumnPattern.find(errorMessage) is regexp:Span;
            boolean hasBadRequestError = badRequestPattern.find(errorMessage) is regexp:Span;
            
            if (hasQuickbooksSyncError || hasNoColumnError || hasBadRequestError) && sfAccount?.QuickbooksSync__c is string {
                // Check if this customer has a parent - if yes, stop the process
                ParentRef? parentRef = qbCustomer?.ParentRef;
                if parentRef is ParentRef {
                    string? parentCustomerId = parentRef?.value;
                    if parentCustomerId is string {
                        // Customer has parent - cannot proceed without custom field
                        log:printError("Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object");
                        log:printError(string `Cannot sync customer ${qbCustomer.DisplayName} with parent ${parentCustomerId} - QuickbooksSync__c field is required for parent hierarchy`);
                        return {
                            success: false,
                            message: "Cannot sync customer with parent - QuickbooksSync__c custom field missing",
                            errorDetails: "Field not there in Salesforce. For updating and having parent customer hierarchy, 'QuickbooksSync__c' custom field should be there in Salesforce. User have to create it in Salesforce Account object"
                        };
                    }
                }
                
                // No parent - retry without QuickbooksSync__c field
                log:printWarn("QuickbooksSync__c field not found in Salesforce. Retrying account creation without this field.");
                log:printWarn("For full function update and parent hierarchy, you have to create custom field 'QuickbooksSync__c' in Salesforce Account object.");
                string qbSyncValue = sfAccount?.QuickbooksSync__c ?: "null";
                log:printInfo(string `Omitting QuickbooksSync__c field (value: ${qbSyncValue}) from account creation for customer: ${qbCustomer.DisplayName}`);
                
                // Create account without QuickbooksSync__c field - completely omit it from the record
                SalesforceAccount sfAccountWithoutCustomField = {
                    Name: sfAccount.Name,
                    Site: sfAccount?.Site,
                    Phone: sfAccount?.Phone,
                    Fax: sfAccount?.Fax,
                    Website: sfAccount?.Website,
                    BillingStreet: sfAccount?.BillingStreet,
                    BillingCity: sfAccount?.BillingCity,
                    BillingState: sfAccount?.BillingState,
                    BillingPostalCode: sfAccount?.BillingPostalCode,
                    BillingCountry: sfAccount?.BillingCountry,
                    ShippingStreet: sfAccount?.ShippingStreet,
                    ShippingCity: sfAccount?.ShippingCity,
                    ShippingState: sfAccount?.ShippingState,
                    ShippingPostalCode: sfAccount?.ShippingPostalCode,
                    ShippingCountry: sfAccount?.ShippingCountry,
                    ParentId: sfAccount?.ParentId,
                    Description: sfAccount?.Description,
                    Type: sfAccount?.Type
                };
                
                salesforce:CreationResponse|error retryResult = salesforceClient->create("Account", sfAccountWithoutCustomField);
                
                if retryResult is error {
                    return {
                        success: false,
                        message: "Error creating Salesforce account (retry also failed)",
                        errorDetails: retryResult.message()
                    };
                }
                
                string createdAccountId = retryResult.id;
                accountId = createdAccountId;
                log:printInfo(string `Created new account ${createdAccountId} for QuickBooks customer ${qbCustomer.Id} (without QuickbooksSync__c field)`);
            } else {
                return {
                    success: false,
                    message: "Error creating Salesforce account",
                    errorDetails: createResult.message()
                };
            }
        } else {
            string createdAccountId = createResult.id;
            accountId = createdAccountId;
            log:printInfo(string `Created new account ${createdAccountId} for QuickBooks customer ${qbCustomer.Id}`);
        }
    }
    
    return {
        success: true,
        accountId: accountId,
        message: "Customer synced successfully"
    };
}
