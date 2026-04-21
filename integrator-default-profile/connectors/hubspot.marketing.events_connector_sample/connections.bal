import ballerinax/hubspot.marketing.events;

final events:Client eventsClient = check new ({ auth: { token: hubspotBearerToken } });
