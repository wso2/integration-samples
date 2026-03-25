import ballerina/log;
import ballerinax/trigger.shopify;
import ballerinax/salesforce;

// Map Shopify customer event to Salesforce contact with all available fields
public function mapShopifyCustomerToSalesforceContact(
    shopify:CustomerEvent customerEvent,
    string? accountId = ()
) returns SalesforceContact {
    // Basic customer information
    string? firstName = customerEvent?.first_name;
    string? lastName = customerEvent?.last_name;
    string? email = customerEvent?.email;
    string? phone = customerEvent?.phone;
    
    // Initialize contact with basic fields
    SalesforceContact contact = {
        LastName: lastName ?: "Unknown",
        FirstName: firstName,
        Email: email,
        Phone: phone,
        AccountId: accountId,
        LeadSource: salesforceConfig.defaultLeadSource
    };
    
    // Set default owner if configured
    if salesforceConfig.ownerIdDefault is string {
        contact.OwnerId = salesforceConfig.ownerIdDefault;
    }
    
    // Convert to JSON to access nested fields
    json customerJson = customerEvent.toJson();
    
    // Map default address to Salesforce mailing address fields
    json|error defaultAddressJson = customerJson.default_address;
    if defaultAddressJson is json && defaultAddressJson != () {
        json|error address1Json = defaultAddressJson.address1;
        json|error address2Json = defaultAddressJson.address2;
        json|error cityJson = defaultAddressJson.city;
        json|error provinceJson = defaultAddressJson.province;
        json|error zipJson = defaultAddressJson.zip;
        json|error countryJson = defaultAddressJson.country;
        json|error phoneJson = defaultAddressJson.phone;
        
        if address1Json is string {
            contact.MailingStreet = address1Json;
        }
        
        // Append address2 to street if available
        if address2Json is string && address2Json.trim() != "" {
            string? existingStreet = contact.MailingStreet;
            if existingStreet is string {
                contact.MailingStreet = existingStreet + ", " + address2Json;
            } else {
                contact.MailingStreet = address2Json;
            }
        }
        
        if cityJson is string {
            contact.MailingCity = cityJson;
        }
        
        if provinceJson is string {
            contact.MailingState = provinceJson;
        }
        
        if zipJson is string {
            contact.MailingPostalCode = zipJson;
        }
        
        if countryJson is string {
            contact.MailingCountry = countryJson;
        }
        
        // Use address phone if main phone is not available
        if phone is () && phoneJson is string {
            contact.Phone = phoneJson;
        }
        
        // Map to other phone if main phone already exists
        if phone is string && phoneJson is string && phone != phoneJson {
            contact.OtherPhone = phoneJson;
        }
    }
    
    // Map marketing consent fields
    json|error emailMarketingConsentJson = customerJson.email_marketing_consent;
    if emailMarketingConsentJson is json && emailMarketingConsentJson != () {
        json|error consentStateJson = emailMarketingConsentJson.state;
        
        if consentStateJson is string {
            // Map to Salesforce's HasOptedOutOfEmail field (inverted logic)
            contact.HasOptedOutOfEmail = consentStateJson != "subscribed";
        }
    }
    
    // Map SMS marketing consent to DoNotCall field
    json|error smsMarketingConsentJson = customerJson.sms_marketing_consent;
    if smsMarketingConsentJson is json && smsMarketingConsentJson != () {
        json|error smsConsentStateJson = smsMarketingConsentJson.state;
        
        if smsConsentStateJson is string {
            // Map to Salesforce's DoNotCall field (inverted logic)
            contact.DoNotCall = smsConsentStateJson != "subscribed";
        }
    }
    
    // Build comprehensive description with all metadata
    string enrichedDescription = buildCustomerDescription(customerEvent, customerJson);
    contact.Description = enrichedDescription;
    
    return contact;
}

// Add Shopify tag to contact after creation/update
public function addShopifyTagToContact(string contactId) returns error? {
    // Create tag for Shopify origin
    salesforce:CreationResponse|error tagResponse = salesforceClient->create(
        sObjectName = "Tag",
        sObject = {
            "Name": "Shopify",
            "Type": "Public"
        }
    );
    
    string tagId = "";
    if tagResponse is salesforce:CreationResponse {
        if tagResponse.success {
            tagId = tagResponse.id;
            log:printInfo("Created Shopify tag", tagId = tagId);
        } else {
            // Tag might already exist, try to find it
            string soqlQuery = "SELECT Id FROM Tag WHERE Name = 'Shopify' LIMIT 1";
            stream<record {| string Id; |}, error?> resultStream = check salesforceClient->query(soql = soqlQuery);
            
            record {|record {| string Id; |} value;|}? result = check resultStream.next();
            check resultStream.close();
            
            if result is record {|record {| string Id; |} value;|} {
                tagId = result.value.Id;
                log:printInfo("Found existing Shopify tag", tagId = tagId);
            } else {
                log:printError("Failed to create or find Shopify tag");
                return;
            }
        }
    } else {
        // Tag might already exist, try to find it
        string soqlQuery = "SELECT Id FROM Tag WHERE Name = 'Shopify' LIMIT 1";
        stream<record {| string Id; |}, error?> resultStream = check salesforceClient->query(soql = soqlQuery);
        
        record {|record {| string Id; |} value;|}? result = check resultStream.next();
        check resultStream.close();
        
        if result is record {|record {| string Id; |} value;|} {
            tagId = result.value.Id;
            log:printInfo("Found existing Shopify tag", tagId = tagId);
        } else {
            log:printError("Failed to create or find Shopify tag");
            return;
        }
    }
    
    // Associate tag with contact
    salesforce:CreationResponse|error tagAssocResult = salesforceClient->create(
        sObjectName = "TagDefinition",
        sObject = {
            "TagId": tagId,
            "EntityId": contactId,
            "Type": "Contact"
        }
    );
    
    if tagAssocResult is error {
        log:printError("Failed to associate tag with contact", 'error = tagAssocResult);
        return tagAssocResult;
    }
    
    if tagAssocResult is salesforce:CreationResponse && !tagAssocResult.success {
        log:printError("Failed to associate tag with contact", errors = tagAssocResult.errors);
        return error("Failed to associate tag");
    }
    
    log:printInfo("Successfully tagged contact as Shopify origin", contactId = contactId);
}

// Build comprehensive description from all available customer data
function buildCustomerDescription(shopify:CustomerEvent customerEvent, json customerJson) returns string {
    int? customerId = customerEvent?.id;
    string description = string `Shopify Customer ID: ${customerId.toString()}`;
    
    // Add order statistics
    string? totalSpent = customerEvent?.total_spent;
    if totalSpent is string && totalSpent.trim() != "" {
        description = description + string ` | Total Spent: ${totalSpent}`;
    }
    
    int? ordersCount = customerEvent?.orders_count;
    if ordersCount is int {
        description = description + string ` | Orders Count: ${ordersCount}`;
    }
    
    // Add customer state
    json|error stateJson = customerJson.state;
    if stateJson is string {
        description = description + string ` | State: ${stateJson}`;
    }
    
    // Add verified email status
    json|error verifiedEmailJson = customerJson.verified_email;
    if verifiedEmailJson is boolean {
        description = description + string ` | Email Verified: ${verifiedEmailJson.toString()}`;
    }
    
    // Add tax exempt status
    json|error taxExemptJson = customerJson.tax_exempt;
    if taxExemptJson is boolean {
        description = description + string ` | Tax Exempt: ${taxExemptJson.toString()}`;
    }
    
    // Add tags if available
    json|error tagsJson = customerJson.tags;
    if tagsJson is string && tagsJson.trim() != "" {
        description = description + string ` | Tags: ${tagsJson}`;
    }
    
    // Add note if available
    json|error noteJson = customerJson.note;
    if noteJson is string && noteJson.trim() != "" {
        // Truncate note if too long
        string noteValue = noteJson;
        if noteValue.length() > 100 {
            noteValue = noteValue.substring(0, 97) + "...";
        }
        description = description + string ` | Note: ${noteValue}`;
    }
    
    // Add currency
    json|error currencyJson = customerJson.currency;
    if currencyJson is string {
        description = description + string ` | Currency: ${currencyJson}`;
    }
    
    // Add marketing consent details
    json|error emailMarketingConsentJson = customerJson.email_marketing_consent;
    if emailMarketingConsentJson is json && emailMarketingConsentJson != () {
        json|error consentStateJson = emailMarketingConsentJson.state;
        json|error consentUpdatedAtJson = emailMarketingConsentJson.consent_updated_at;
        
        if consentStateJson is string {
            description = description + string ` | Email Marketing: ${consentStateJson}`;
        }
        
        if consentUpdatedAtJson is string {
            description = description + string ` | Email Consent Updated: ${consentUpdatedAtJson}`;
        }
    }
    
    // Add SMS marketing consent details
    json|error smsMarketingConsentJson = customerJson.sms_marketing_consent;
    if smsMarketingConsentJson is json && smsMarketingConsentJson != () {
        json|error smsConsentStateJson = smsMarketingConsentJson.state;
        json|error smsConsentUpdatedAtJson = smsMarketingConsentJson.consent_updated_at;
        
        if smsConsentStateJson is string {
            description = description + string ` | SMS Marketing: ${smsConsentStateJson}`;
        }
        
        if smsConsentUpdatedAtJson is string {
            description = description + string ` | SMS Consent Updated: ${smsConsentUpdatedAtJson}`;
        }
    }
    
    // Add timestamps
    json|error createdAtJson = customerJson.created_at;
    if createdAtJson is string {
        description = description + string ` | Created: ${createdAtJson}`;
    }
    
    json|error updatedAtJson = customerJson.updated_at;
    if updatedAtJson is string {
        description = description + string ` | Updated: ${updatedAtJson}`;
    }
    
    return description;
}

// Extract domain from email for account matching
public function extractDomainFromEmail(string email) returns string? {
    int? atIndex = email.indexOf("@");
    if atIndex is int && atIndex > 0 {
        return email.substring(atIndex + 1);
    }
    return ();
}

// Extract company name from customer event
public function extractCompanyName(shopify:CustomerEvent customerEvent) returns string? {
    json customerJson = customerEvent.toJson();
    
    // Extract company from default address
    json|error defaultAddressJson = customerJson.default_address;
    if defaultAddressJson is json && defaultAddressJson != () {
        json|error companyJson = defaultAddressJson.company;
        if companyJson is string && companyJson.trim() != "" {
            return companyJson;
        }
    }
    
    return ();
}
