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
    foreach CcRecipient ccRecipient in businessRulesConfig.ccRecipients {
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
    dsesign:EnvelopeSummary envelopeSummary = check docusignClient->/accounts/[docusignConfig.accountId]/envelopes.post(envelopeDefinition);
    
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
    
    foreach FieldMapping mapping in businessRulesConfig.fieldMappings {
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
    Opportunity|error opportunityResult = getOpportunity(opportunityId);
    if opportunityResult is error {
        log:printError(string `Failed to get opportunity ${opportunityId}: ${opportunityResult.message()}`);
        return opportunityResult;
    }
    Opportunity opportunity = opportunityResult;
    log:printInfo(string `Retrieved opportunity: ${opportunity.Name}, Stage: ${opportunity.StageName}`);
    
    // Validate opportunity data
    error? validationResult = validateOpportunityData(opportunity);
    if validationResult is error {
        log:printError(string `Opportunity validation failed: ${validationResult.message()}`);
        return validationResult;
    }
    
    // Check if opportunity meets dispatch criteria
    if !meetsDispatchCriteria(opportunity) {
        log:printInfo(string `Opportunity ${opportunityId} does not meet dispatch criteria`);
        return;
    }
    
    // Get signer contact based on configured role
    Contact|error signerResult = getSignerContact(opportunityId);
    if signerResult is error {
        log:printError(string `Failed to get signer contact: ${signerResult.message()}`);
        return signerResult;
    }
    Contact signer = signerResult;
    
    // Validate contact data
    error? contactValidationResult = validateContactData(signer);
    if contactValidationResult is error {
        log:printError(string `Contact validation failed: ${contactValidationResult.message()}`);
        return contactValidationResult;
    }
    
    // Select appropriate template
    TemplateConfig templateConfig = selectTemplate(opportunity);
    log:printInfo(string `Selected template: ${templateConfig.templateId}`);
    
    // Create and send DocuSign envelope
    string|error envelopeResult = createAndSendEnvelope(opportunity, signer, templateConfig);
    if envelopeResult is error {
        log:printError(string `Failed to create DocuSign envelope: ${envelopeResult.message()}`);
        return envelopeResult;
    }
    string envelopeId = envelopeResult;
    
    log:printInfo(string `DocuSign envelope ${envelopeId} sent for opportunity ${opportunityId}`);
    
    // Update opportunity stage to "Contract Sent"
    error? updateResult = updateOpportunityStage(opportunityId, businessRulesConfig.contractSentStage);
    if updateResult is error {
        log:printWarn(string `Failed to update opportunity stage: ${updateResult.message()}`);
    }
    
    log:printInfo(string `Successfully processed opportunity ${opportunityId}`);
}

// Get signer contact based on configured role
function getSignerContact(string opportunityId) returns Contact|error {
    // Try to get contact by configured role
    Contact|error contactResult = getContactByRole(opportunityId, businessRulesConfig.signerRole);
    
    if contactResult is Contact {
        return contactResult;
    }
    
    // Fallback to primary contact
    log:printWarn(string `Could not find contact with role ${businessRulesConfig.signerRole}, falling back to primary contact`);
    Contact primaryContact = check getPrimaryContact(opportunityId);
    return primaryContact;
}
