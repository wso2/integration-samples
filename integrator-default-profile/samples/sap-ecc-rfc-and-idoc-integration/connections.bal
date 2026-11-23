import ballerinax/sap.jco;

final jco:Client jcoClient = check new (<jco:DestinationConfig>{ashost: sapHost, sysnr: sapSystemNumber, jcoClient: sapClient, user: sapUser, passwd: sapPassword});
