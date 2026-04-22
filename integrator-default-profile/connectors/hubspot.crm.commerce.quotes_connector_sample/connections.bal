import ballerinax/hubspot.crm.commerce.quotes;

final quotes:Client quotesClient = check new ({auth: {token: hubspotQuotesToken}}, string `${hubspotQuotesServiceUrl}`);
