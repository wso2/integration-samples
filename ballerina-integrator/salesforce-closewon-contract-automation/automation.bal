import ballerina/log;
import ballerinax/docusign.dsesign;

// Create and send DocuSign envelope using the connector
function createAndSendEnvelope(Opportunity opportunity, Contact signer, TemplateConfig templateConfig) returns string|error {
    // Build signer name
    string signerName = buildSignerName(signer);
    
    // Build pre-fill fields
    record {string name; string value;}[] templateFields = buildTemplateFields(opportunity);
    
    // Get signer email
    string? signerEmail = signer.Email;
    if signerEmail is () {
        return error("Contact email is required");
    }
    
    // Get opportunity name
    string? opportunityName = opportunity.Name;
    string emailSubject = opportunityName is string ? string `Contract for ${opportunityName}` : "Contract";
    
    log:printInfo(string `Creating envelope with template: ${templateConfig.templateId}`);
    log:printInfo(string `Signer: ${signerName} (${signerEmail})`);
    log:printInfo(string `Email subject: ${emailSubject}`);
    
    // Build template roles
    dsesign:TemplateRole[] templateRoles = [];
    
    // Add signer
    dsesign:TemplateRole signerRole = {
        email: signerEmail,
        name: signerName,
        roleName: "Signer",
        routingOrder: "1"
    };
    
    // Add tabs for pre-filled fields
    if templateFields.length() > 0 {
        log:printInfo(string `Adding ${templateFields.length()} pre-filled fields`);
        dsesign:Text[] textTabs = [];
        
        foreach record {string name; string value;} templateField in templateFields {
            log:printInfo(string `Field: ${templateField.name} = ${templateField.value}`);
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
    
    // Add CC recipients if configured
    if businessRulesConfig.ccRecipients.length() > 0 {
        log:printInfo(string `Adding ${businessRulesConfig.ccRecipients.length()} CC recipients`);
        int ccOrder = 2;
        foreach CcRecipient ccRecipient in businessRulesConfig.ccRecipients {
            log:printInfo(string `CC: ${ccRecipient.name} (${ccRecipient.email})`);
            dsesign:TemplateRole ccRole = {
                email: ccRecipient.email,
                name: ccRecipient.name,
                roleName: "CC",
                routingOrder: ccOrder.toString()
            };
            templateRoles.push(ccRole);
            ccOrder = ccOrder + 1;
        }
    }
    
    // Create envelope definition for DocuSign API
    // Note: When using templates, ensure the template has documents attached in DocuSign
    // We'll create the envelope in "sent" status to immediately send it
    dsesign:EnvelopeDefinition envelopeDefinition = {
        emailSubject: emailSubject,
        templateId: templateConfig.templateId,
        templateRoles: templateRoles,
        status: "sent"
    };
    
    // Create and send envelope using DocuSign client
    log:printInfo("Sending envelope creation request to DocuSign...");
    log:printInfo(string `Template ID: ${templateConfig.templateId}`);
    log:printInfo(string `Email Subject: ${emailSubject}`);
    log:printInfo(string `Number of template roles: ${templateRoles.length()}`);
    
    dsesign:EnvelopeSummary|error envelopeResult = docusignClient->/accounts/[docusignConfig.accountId]/envelopes.post(envelopeDefinition);
    
    if envelopeResult is error {
        log:printError(string `DocuSign API error: ${envelopeResult.message()}`);
        log:printError(string `Error detail: ${envelopeResult.toString()}`);
        
        // Provide helpful error messages
        string errorMsg = envelopeResult.message();
        if errorMsg.includes("ENVELOPE_IS_INCOMPLETE") {
            log:printError("TROUBLESHOOTING: The template must have documents attached in DocuSign.");
            log:printError("Please verify in DocuSign: Templates > Select your template > Ensure documents are added");
            log:printError(string `Template ID being used: ${templateConfig.templateId}`);
        }
        
        return error(string `Failed to create DocuSign envelope: ${envelopeResult.message()}`);
    }
    
    dsesign:EnvelopeSummary envelopeSummary = envelopeResult;
    string? envelopeId = envelopeSummary.envelopeId;
    
    if envelopeId is () {
        return error("Failed to create envelope: No envelope ID returned");
    }
    
    log:printInfo(string `DocuSign envelope created and sent successfully: ${envelopeId}`);
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
    string? lastName = contact.LastName;
    
    if firstName is string && lastName is string {
        return string `${firstName} ${lastName}`;
    }
    
    if lastName is string {
        return lastName;
    }
    
    if firstName is string {
        return firstName;
    }
    
    return "Signer";
}

// Validate DocuSign configuration
function validateDocusignConfig() returns error? {
    if docusignConfig.accountId.trim() == "" {
        return error("DocuSign account ID is not configured");
    }
    
    if docusignConfig.clientId.trim() == "" {
        return error("DocuSign client ID is not configured");
    }
    
    if docusignConfig.clientSecret.trim() == "" {
        return error("DocuSign client secret is not configured");
    }
    
    if docusignConfig.refreshToken.trim() == "" {
        return error("DocuSign refresh token is not configured");
    }
    
    // Log reminder about template requirements
    log:printInfo("REMINDER: Ensure your DocuSign template has documents attached and a 'Signer' role defined");
}

// Process opportunity for contract dispatch
public function processOpportunityForContract(string opportunityId) returns error? {
    log:printInfo(string `Processing opportunity ${opportunityId} for contract dispatch`);
    
    // Validate DocuSign configuration
    error? configValidation = validateDocusignConfig();
    if configValidation is error {
        log:printError(string `DocuSign configuration error: ${configValidation.message()}`);
        return configValidation;
    }
    
    // Get opportunity details
    Opportunity|error opportunityResult = getOpportunity(opportunityId);
    if opportunityResult is error {
        log:printError(string `Failed to get opportunity ${opportunityId}: ${opportunityResult.message()}`);
        return opportunityResult;
    }
    Opportunity opportunity = opportunityResult;
    string? opportunityName = opportunity.Name;
    string? stageName = opportunity.StageName;
    string nameStr = opportunityName is string ? opportunityName : "Unknown";
    string stageStr = stageName is string ? stageName : "Unknown";
    log:printInfo(string `Retrieved opportunity: ${nameStr}, Stage: ${stageStr}`);
    
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
    
    // Validate template ID
    if templateConfig.templateId.trim() == "" {
        error templateError = error("Template ID is empty. Please configure 'defaultTemplateId' in templateSettings configuration. You can find your template ID in Docusign: Templates > Select template > Copy ID from URL.");
        log:printError(templateError.message());
        return templateError;
    }
    
    log:printInfo("IMPORTANT: Before sending, verify your DocuSign template:");
    log:printInfo("  1. Has at least one document attached (PDF/Word/etc.)");
    log:printInfo("  2. Has a recipient role named 'Signer' (case-sensitive)");
    log:printInfo("  3. Is in 'Active' status");
    log:printInfo(string `  Template ID: ${templateConfig.templateId}`);
    
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
