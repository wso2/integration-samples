import ballerina/log;
import ballerinax/docusign.dsesign;

// Create and send DocuSign envelope using the connector
function createAndSendEnvelope(Opportunity opportunity, Contact signer, TemplateConfig templateConfig) returns string|error {
    // Build signer name
    string signerName = buildSignerName(signer);
    
    // Build pre-fill fields
    record {string name; string value;}[] templateFields = buildTemplateFields(opportunity);
    
    // Build signer info
    SignerInfo signerInfo = {
        email: signer.Email,
        name: signerName,
        roleName: "Signer",
        routingOrder: 1
    };
    
    // Build CC recipients if configured
    CarbonCopy[] carbonCopies = [];
    int ccRoutingOrder = 2;
    foreach CcRecipient ccRecipient in ccRecipients {
        CarbonCopy ccCopy = {
            email: ccRecipient.email,
            name: ccRecipient.name,
            routingOrder: ccRoutingOrder
        };
        carbonCopies.push(ccCopy);
        ccRoutingOrder = ccRoutingOrder + 1;
    }
    
    // Create envelope definition for DocuSign API
    dsesign:EnvelopeDefinition envelopeDefinition = {
        emailSubject: string `Contract for ${opportunity.Name}`,
        templateId: templateConfig.templateId,
        status: "sent"
    };
    
    // Add expiration configuration if specified
    int? expirationDays = templateConfig.expirationDays;
    if expirationDays is int {
        envelopeDefinition.notification = {
            expirations: {
                expireEnabled: "true",
                expireAfter: expirationDays.toString(),
                expireWarn: "0"
            }
        };
    }
    
    // Build template roles
    dsesign:TemplateRole[] templateRoles = [];
    
    // Add signer
    dsesign:TemplateRole signerRole = {
        email: signerInfo.email,
        name: signerInfo.name,
        roleName: signerInfo.roleName,
        routingOrder: "1"
    };
    
    // Add tabs for pre-filled fields
    if templateFields.length() > 0 {
        dsesign:Text[] textTabs = [];
        
        foreach record {string name; string value;} templateField in templateFields {
            dsesign:Text textTab = {
                tabLabel: templateField.name,
                value: templateField.value
            };
            textTabs.push(textTab);
        }
        
        dsesign:Tabs tabs = {
            textTabs: textTabs
        };
        
        signerRole.tabs = tabs;
    }
    
    templateRoles.push(signerRole);
    
    // Add CC recipients
    int ccOrder = 2;
    foreach CarbonCopy cc in carbonCopies {
        dsesign:TemplateRole ccRole = {
            email: cc.email,
            name: cc.name,
            roleName: "CC",
            routingOrder: ccOrder.toString()
        };
        templateRoles.push(ccRole);
        ccOrder = ccOrder + 1;
    }
    
    envelopeDefinition.templateRoles = templateRoles;
    
    // Create envelope using DocuSign client
    dsesign:EnvelopeSummary envelopeSummary = check docusignClient->/accounts/[docusignAccountId]/envelopes.post(envelopeDefinition);
    
    string? envelopeId = envelopeSummary.envelopeId;
    if envelopeId is () {
        return error("Failed to create envelope: No envelope ID returned");
    }
    
    log:printInfo(string `DocuSign envelope created successfully: ${envelopeId}`);
    return envelopeId;
}

// Build template fields from opportunity data
function buildTemplateFields(Opportunity opportunity) returns record {string name; string value;}[] {
    record {string name; string value;}[] fields = [];
    
    foreach FieldMapping mapping in fieldMappings {
        string opportunityField = mapping.opportunityField;
        string docusignField = mapping.docusignField;
        
        // Get field value from opportunity
        string fieldValue = getOpportunityFieldValue(opportunity, opportunityField);
        
        if fieldValue != "" {
            fields.push({
                name: docusignField,
                value: fieldValue
            });
        }
    }
    
    return fields;
}

// Build signer name from contact
function buildSignerName(Contact contact) returns string {
    string? firstName = contact.FirstName;
    string lastName = contact.LastName;
    
    if firstName is string {
        return string `${firstName} ${lastName}`;
    }
    
    return lastName;
}

// Process opportunity for contract dispatch
public function processOpportunityForContract(string opportunityId) returns error? {
    log:printInfo(string `Processing opportunity ${opportunityId} for contract dispatch`);
    
    // Get opportunity details
    Opportunity opportunity = check getOpportunity(opportunityId);
    
    // Validate opportunity data
    check validateOpportunityData(opportunity);
    
    // Check if opportunity meets dispatch criteria
    if !meetsDispatchCriteria(opportunity) {
        log:printInfo(string `Opportunity ${opportunityId} does not meet dispatch criteria`);
        return;
    }
    
    // Idempotency check: Skip if envelope already sent
    boolean alreadyProcessed = check hasEnvelopeAlreadySent(opportunityId, opportunity);
    if alreadyProcessed {
        log:printInfo(string `Opportunity ${opportunityId} already has envelope sent, skipping duplicate processing`);
        return;
    }
    
    // Get signer contact based on configured role
    Contact signer = check getSignerContact(opportunityId);
    
    // Validate contact data
    check validateContactData(signer);
    
    // Select appropriate template
    TemplateConfig templateConfig = selectTemplate(opportunity);
    
    // Create and send DocuSign envelope
    string envelopeId = check createAndSendEnvelope(opportunity, signer, templateConfig);
    
    log:printInfo(string `DocuSign envelope ${envelopeId} sent for opportunity ${opportunityId}`);
    
    // Update opportunity stage to "Contract Sent" with envelope ID
    check updateOpportunityStage(opportunityId, contractSentStage, envelopeId);
    
    log:printInfo(string `Successfully processed opportunity ${opportunityId}`);
}

// Check if envelope has already been sent for this opportunity (idempotency check)
function hasEnvelopeAlreadySent(string opportunityId, Opportunity opportunity) returns boolean|error {
    // Check if opportunity stage is already "Contract Sent" or beyond
    if opportunity.StageName == contractSentStage {
        log:printInfo(string `Opportunity ${opportunityId} is already in stage ${contractSentStage}`);
        return true;
    }
    
    // Check if there's a DocuSign envelope ID stored in a custom field
    // Note: This requires a custom field on Opportunity object (e.g., DocuSign_Envelope_Id__c)
    // For now, we rely on stage check as the primary idempotency mechanism
    boolean hasEnvelopeMarker = check checkEnvelopeMarker(opportunityId);
    if hasEnvelopeMarker {
        log:printInfo(string `Opportunity ${opportunityId} already has envelope marker`);
        return true;
    }
    
    return false;
}

// Get signer contact based on configured role
function getSignerContact(string opportunityId) returns Contact|error {
    // Try to get contact by configured role
    Contact|error contactResult = getContactByRole(opportunityId, signerRole);
    
    if contactResult is Contact {
        return contactResult;
    }
    
    // Fallback to primary contact
    log:printWarn(string `Could not find contact with role ${signerRole}, falling back to primary contact`);
    Contact primaryContact = check getPrimaryContact(opportunityId);
    return primaryContact;
}
