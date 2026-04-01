public function mapLeadToRow(Lead lead) returns SheetRow|error {
    map<int|string|decimal|boolean|float> leadMap = {
        "Id": lead?.Id ?: "",
        "FirstName": lead?.FirstName ?: "",
        "LastName": lead?.LastName ?: "",
        "Email": lead?.Email ?: "",
        "Phone": lead?.Phone ?: "",
        "Company": lead?.Company ?: "",
        "Title": lead?.Title ?: "",
        "Status": lead?.Status ?: "",
        "LeadSource": lead?.LeadSource ?: "",
        "Industry": lead?.Industry ?: "",
        "Rating": lead?.Rating ?: "",
        "OwnerId": lead?.OwnerId ?: "",
        "Description": lead?.Description ?: "",
        "Website": lead?.Website ?: "",
        "Country": lead?.Country ?: "",
        "City": lead?.City ?: "",
        "State": lead?.State ?: "",
        "IsConverted": lead?.IsConverted ?: "",
        "ConvertedDate": lead?.ConvertedDate ?: "",
        "CreatedDate": lead?.CreatedDate ?: "",
        "LastModifiedDate": lead?.LastModifiedDate ?: "",
        "LastActivityDate": lead?.LastActivityDate ?: "",
        "NumberOfEmployees": lead?.NumberOfEmployees ?: "",
        "AnnualRevenue": lead?.AnnualRevenue ?: ""
    };

    SheetRow row = [];
    foreach string fieldName in fieldMapping {
        if !leadMap.hasKey(fieldName) {
            return error(string `Invalid field name in fieldMapping: "${fieldName}". Supported fields are: ${string:'join(", ", ...leadMap.keys())}`);
        }
        int|string|decimal|boolean|float fieldValue = leadMap.get(fieldName);
        row.push(fieldValue);
    }
    return row;
}
