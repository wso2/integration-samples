import ballerinax/sap.s4hana.api_salesdistrict_srv;

final api_salesdistrict_srv:Client apiSalesdistrictSrvClient = check new ({auth: {username: sapUsername, password: sapPassword}}, sapHostname);
