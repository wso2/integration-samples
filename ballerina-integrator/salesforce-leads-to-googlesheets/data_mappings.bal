public function mapLeadToRow(Lead lead) returns SheetRow {
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
        "IsConverted": lead?.IsConverted ?: false,
        "ConvertedDate": lead?.ConvertedDate ?: "",
        "CreatedDate": lead?.CreatedDate ?: "",
        "LastModifiedDate": lead?.LastModifiedDate ?: "",
        "LastActivityDate": lead?.LastActivityDate ?: "",
        "NumberOfEmployees": lead?.NumberOfEmployees ?: 0,
        "AnnualRevenue": lead?.AnnualRevenue ?: 0.0
    };

    SheetRow row = [];
    foreach string fieldName in fieldMapping {
        int|string|decimal|boolean|float fieldValue = leadMap.hasKey(fieldName) ? leadMap.get(fieldName) : "";
        row.push(fieldValue);
    }
    return row;
}
