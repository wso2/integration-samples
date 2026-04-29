import ballerinax/sap.s4hana.ce_salesorder_0001;

final ce_salesorder_0001:Client ceSalesorder0001Client = check new ({auth: {token: sapAuthToken}}, string `${sapHostname}`);
