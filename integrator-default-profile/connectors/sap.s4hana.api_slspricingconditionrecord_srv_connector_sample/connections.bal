import ballerinax/sap.s4hana.api_slspricingconditionrecord_srv;

final api_slspricingconditionrecord_srv:Client apiSlspricingconditionrecordSrvClient = check new ({auth: {username, password}}, string `${sapHostname}`);
