import ballerinax/sap.s4hana.api_sd_incoterms_srv;

final api_sd_incoterms_srv:Client apiSdIncotermsSrvClient = check new ({
    auth: {
        username: sapUsername,
        password: sapPassword
    }
}, string `${sapHostname}`);
