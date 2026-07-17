import ballerina/log;
import ballerinax/sap.businessone.fixedassets;

public function main() returns error? {
    do {
        fixedassets:AssetDocument result = check fixedassetsClient->createAssetCapitalization({PostingDate: "2026-07-14", DocumentDate: "2026-07-14", Remarks: "Fixed asset capitalization created via sample integration", Currency: "USD"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

