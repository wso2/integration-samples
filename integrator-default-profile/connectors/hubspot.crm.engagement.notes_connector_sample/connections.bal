import ballerinax/hubspot.crm.engagement.notes;

final notes:Client notesClient = check new ({auth: {token: hubspotToken}});
