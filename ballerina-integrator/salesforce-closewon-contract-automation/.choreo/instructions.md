## What It Does

- Listens to Salesforce Opportunity change events and validates business criteria (Closed Won stage, minimum deal value)
- Retrieves contact details and selects the appropriate Docusign template based on opportunity type
- Creates and sends Docusign envelope with pre-filled fields from Salesforce
- Updates Salesforce opportunity stage to "Contract Sent"

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. **Change Data Capture** enabled for the Opportunity object
3. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
4. Username and password (with security token) for event listener

This integration uses both username/password authentication for the listener and refresh token flow for API calls. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>

<summary>Docusign Setup Guide</summary>

### Prerequisites

1. A Docusign account (demo or production)
2. Contract templates created with named fields
3. OAuth2 credentials:
   - Account ID
   - Access Token
4. Scopes Required:
   - `signature`
   - `impersonation`

### Setup Steps

1. **Create Templates**:
   - Log in to Docusign
   - Go to Templates → New Template
   - Add fields with labels matching your field mappings (e.g., "OpportunityName", "ContractValue", "CloseDate")
   - Note Template ID from template settings

2. **Generate Access Token**:
   - Go to Settings → Apps and Keys
   - Create new application or use existing
   - Generate access token with required scopes
   - Note Account ID and Access Token

This integration uses the official `ballerinax/docusign.dsesign` connector with access token authentication. [Learn how to get Docusign credentials](https://developers.docusign.com/platform/auth/).

</details>

<details>

<summary>Configuration Parameters</summary>

### Salesforce Credentials

- `salesforceUsername` - Your Salesforce username for listener authentication
- `salesforcePassword` - Your Salesforce password with security token appended
- `salesforceClientId` - Your Salesforce OAuth2 client ID
- `salesforceClientSecret` - Your Salesforce OAuth2 client secret
- `salesforceRefreshToken` - Your Salesforce OAuth2 refresh token
- `salesforceRefreshUrl` - Salesforce OAuth2 token endpoint (default: `https://login.salesforce.com/services/oauth2/token`)
- `salesforceBaseUrl` - Your Salesforce instance URL (default: `https://login.salesforce.com`)
- `salesforceChannelName` - Change event channel (default: `/data/ChangeEvents`)

### Docusign Credentials

- `docusignAccountId` - Your Docusign account ID
- `docusignAccessToken` - Your Docusign OAuth2 access token
- `docusignBaseUrl` - Docusign API base URL (default: `https://demo.docusign.net/restapi` for demo)

### Template Configuration

- `defaultTemplateId` - Default Docusign template ID to use (required)
- `templateConfigs` - Array of template configurations for different product/deal types (optional)
  - `templateId` - Docusign template ID
  - `productType` - Opportunity type to match (optional)
  - `dealType` - Deal type to match (optional)
  - `expirationDays` - Days until expiration reminder (optional)

### Business Rules

- `minimumDealValue` - Minimum opportunity amount to trigger contract (default: `0.0`)
  - Only opportunities with amount >= this value will trigger contract dispatch
- `signerRole` - Contact role to use as signer (default: `"Primary Contact"`)
  - Options: `"Primary Contact"`, `"Billing Contact"`, `"Decision Maker"`, `"Executive Sponsor"`
  - Falls back to primary contact if specified role not found
- `ccRecipients` - Array of CC recipients (optional)
  - `email` - Recipient email address
  - `name` - Recipient name
- `fieldMappings` - Array of field mappings from Salesforce to Docusign (default mappings provided)
  - `opportunityField` - Salesforce Opportunity field name (e.g., "Name", "Amount", "CloseDate")
  - `docusignField` - Docusign template field label (e.g., "OpportunityName", "ContractValue")
- `contractSentStage` - Opportunity stage to set after sending contract (default: `"Contract Sent"`)
- `expirationReminderDays` - Default expiration reminder days (default: `3`)

</details>

<details>

<summary>Field Mapping Examples</summary>

### Default Field Mappings

The integration comes with these default field mappings:

```toml
[[fieldMappings]]
opportunityField = "Name"
docusignField = "OpportunityName"

[[fieldMappings]]
opportunityField = "Amount"
docusignField = "ContractValue"

[[fieldMappings]]
opportunityField = "CloseDate"
docusignField = "CloseDate"
```

### Adding Custom Mappings

You can add additional field mappings to pre-fill more Docusign fields:

```toml
[[fieldMappings]]
opportunityField = "Id"
docusignField = "OpportunityId"

[[fieldMappings]]
opportunityField = "Type"
docusignField = "DealType"

[[fieldMappings]]
opportunityField = "AccountId"
docusignField = "AccountNumber"
```

**Important**: Ensure the `docusignField` values match the exact field labels in your Docusign template.

</details>

<details>

<summary>Template Configuration Examples</summary>

### Single Template Setup

If you use one template for all contracts:

```toml
defaultTemplateId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

### Multiple Templates by Product Type

Configure different templates for different opportunity types:

```toml
defaultTemplateId = "default-template-id"

[[templateConfigs]]
templateId = "enterprise-contract-template-id"
productType = "Enterprise"
expirationDays = 7

[[templateConfigs]]
templateId = "professional-contract-template-id"
productType = "Professional"
expirationDays = 5

[[templateConfigs]]
templateId = "startup-contract-template-id"
productType = "Startup"
dealType = "New Business"
expirationDays = 3
```

The integration will match the opportunity's `Type` field to select the appropriate template.

</details>

<details>

<summary>CC Recipients Configuration</summary>

### Adding CC Recipients

Configure multiple people to receive copies of the contract:

```toml
[[ccRecipients]]
email = "legal@yourcompany.com"
name = "Legal Team"

[[ccRecipients]]
email = "sales-ops@yourcompany.com"
name = "Sales Operations"

[[ccRecipients]]
email = "finance@yourcompany.com"
name = "Finance Department"
```

All CC recipients will receive a copy of the contract when it's sent to the signer.

</details>
