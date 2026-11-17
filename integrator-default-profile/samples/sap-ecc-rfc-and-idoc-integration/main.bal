import ballerina/data.xmldata;
import ballerina/http;
import ballerina/log;
import ballerinax/sap.jco;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /materials on httpDefaultListener {
    resource function get [string material]() returns json|error {
        do {
            jco:RfcRecord materialDetail = check jcoClient->execute("BAPI_MATERIAL_GET_DETAIL", {importParameters: {"MATERIAL": material}});
            jco:RfcRecord generalData = check materialDetail["MATERIAL_GENERAL_DATA"].ensureType();
            return {material: material, description: generalData["MATL_DESC"].toString(), materialType: generalData["MATL_TYPE"].toString(), materialGroup: generalData["MATL_GROUP"].toString(), baseUnit: generalData["BASE_UOM"].toString()};
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}

listener jco:Listener sapListener = new ({gwhost: sapHost, gwserv: sapGatewayService, progid: sapProgramId, repositoryDestination: {ashost: sapHost, sysnr: sapSystemNumber, jcoClient: sapClient, user: sapUser, passwd: sapPassword}});

service jco:IDocService on sapListener {
    remote function onReceive(xml iDoc) returns error? {
        MATMAS05 matmas = check xmldata:parseAsType(iDoc);
        MaterialUpdate materialUpdate = toMaterialUpdate(matmas);
        log:printInfo(string `IDoc ${materialUpdate.idocNumber} mapped: ${materialUpdate.toJsonString()}`);
    }

    remote function onError(error err) returns error? {
        log:printError("IDoc listener error", err);
    }
}

