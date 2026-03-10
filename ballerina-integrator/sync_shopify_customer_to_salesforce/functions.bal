import ballerina/log;
import ballerinax/salesforce;

function findContactByEmail(string email) returns string?|error {
    string soqlQuery = string `SELECT Id FROM Contact WHERE Email = '${email}' LIMIT 1`;
    stream<record {string Id;}, error?> resultStream = check salesforceClient->query(soqlQuery);
    record {|record {string Id;} value;|}? result = check resultStream.next();
    check resultStream.close();
    return result is record {|record {string Id;} value;|} ? result.value.Id : ();
}

function getAccountId(ShopifyCustomer customer) returns string?|error {
    record {string company?;}[]? addresses = customer.addresses;
    if addresses is () || addresses.length() == 0 {
        return ();
    }
    
    string? company = addresses[0].company;
    if company is () || company.trim() == "" {
        return ();
    }
    
    if accountAssociationRule != "CREATE_NEW" {
        string soqlQuery = string `SELECT Id FROM Account WHERE Name = '${company}' LIMIT 1`;
        stream<record {string Id;}, error?> resultStream = check salesforceClient->query(soqlQuery);
        record {|record {string Id;} value;|}? result = check resultStream.next();
        check resultStream.close();
        
        if result is record {|record {string Id;} value;|} {
            log:printInfo(string `Found existing Account: ${result.value.Id}`);
            return result.value.Id;
        }
    }
    
    salesforce:CreationResponse accountResponse = check salesforceClient->create("Account", {"Name": company});
    if accountResponse.success {
        log:printInfo(string `Created new Account: ${accountResponse.id}`);
        return accountResponse.id;
    }
    return ();
}

function createSalesforceContact(ShopifyCustomer customer) returns error? {
    string? accountId = check getAccountId(customer);
    SalesforceContact contact = mapShopifyCustomerToSalesforceContact(customer, accountId);
    salesforce:CreationResponse response = check salesforceClient->create("Contact", contact);

    if response.success {
        log:printInfo(string `Created Contact: ${response.id} for Customer: ${customer.id.toString()}`);
    }
}

function updateSalesforceContact(ShopifyCustomer customer) returns error? {
    string? customerEmail = customer.email;
    if customerEmail is () {
        log:printWarn(string `Cannot update contact for Customer ${customer.id.toString()}: No email`);
        return;
    }

    string? existingContactId = check findContactByEmail(customerEmail);
    if existingContactId is () {
        log:printWarn(string `Contact not found for email: ${customerEmail}`);
        return;
    }

    string? accountId = check getAccountId(customer);
    SalesforceContact contact = mapShopifyCustomerToSalesforceContact(customer, accountId);
    check salesforceClient->update("Contact", existingContactId, contact);
    log:printInfo(string `Updated Contact: ${existingContactId}`);
}

