import ballerinax/sap.successfactors.ecalternativecostdistribution;

final ecalternativecostdistribution:Client ecalternativecostdistributionClient = check new ({auth: {username: userName, password: password}}, hostname);
