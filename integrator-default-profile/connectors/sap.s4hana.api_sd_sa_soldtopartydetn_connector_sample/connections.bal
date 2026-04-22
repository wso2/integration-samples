import ballerinax/sap.s4hana.api_sd_sa_soldtopartydetn;

final api_sd_sa_soldtopartydetn:Client apiSdSaSoldtopartydetnClient = check new ({auth: {username: sapUsername, password: sapPassword}}, hostname);
