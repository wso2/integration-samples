import ballerinax/sap.s4hana.salesarea_0001;

final salesarea_0001:Client salesarea0001Client = check new ({auth: {username: sapUsername, password: sapPassword}}, string `${sapHostname}`);
