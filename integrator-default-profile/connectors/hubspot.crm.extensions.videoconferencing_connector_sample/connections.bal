import ballerinax/hubspot.crm.extensions.videoconferencing;

final videoconferencing:Client videoconferencingClient = check new ({hapikey: hubspotVideoconfHapiKey}, serviceUrl = string `${hubspotVideoconfServiceUrl}`);
