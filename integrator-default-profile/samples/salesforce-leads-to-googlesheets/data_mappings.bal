type LeadFieldMap record {|
    string|int|decimal|boolean|float Id;
    string|int|decimal|boolean|float FirstName;
    string|int|decimal|boolean|float LastName;
    string|int|decimal|boolean|float Email;
    string|int|decimal|boolean|float Phone;
    string|int|decimal|boolean|float Company;
    string|int|decimal|boolean|float Title;
    string|int|decimal|boolean|float Status;
    string|int|decimal|boolean|float LeadSource;
    string|int|decimal|boolean|float Industry;
    string|int|decimal|boolean|float Rating;
    string|int|decimal|boolean|float OwnerId;
    string|int|decimal|boolean|float Description;
    string|int|decimal|boolean|float Website;
    string|int|decimal|boolean|float Country;
    string|int|decimal|boolean|float City;
    string|int|decimal|boolean|float State;
    string|int|decimal|boolean|float IsConverted;
    string|int|decimal|boolean|float ConvertedDate;
    string|int|decimal|boolean|float CreatedDate;
    string|int|decimal|boolean|float LastModifiedDate;
    string|int|decimal|boolean|float LastActivityDate;
    string|int|decimal|boolean|float NumberOfEmployees;
    string|int|decimal|boolean|float AnnualRevenue;
|};

function getLeadFieldMap(Lead lead) returns LeadFieldMap => {
    Id: lead?.Id ?: "",
    FirstName: lead?.FirstName ?: "",
    LastName: lead?.LastName ?: "",
    Email: lead?.Email ?: "",
    Phone: lead?.Phone ?: "",
    Company: lead?.Company ?: "",
    Title: lead?.Title ?: "",
    Status: lead?.Status ?: "",
    LeadSource: lead?.LeadSource ?: "",
    Industry: lead?.Industry ?: "",
    Rating: lead?.Rating ?: "",
    OwnerId: lead?.OwnerId ?: "",
    Description: lead?.Description ?: "",
    Website: lead?.Website ?: "",
    Country: lead?.Country ?: "",
    City: lead?.City ?: "",
    State: lead?.State ?: "",
    IsConverted: lead?.IsConverted ?: "",
    ConvertedDate: lead?.ConvertedDate ?: "",
    CreatedDate: lead?.CreatedDate ?: "",
    LastModifiedDate: lead?.LastModifiedDate ?: "",
    LastActivityDate: lead?.LastActivityDate ?: "",
    NumberOfEmployees: lead?.NumberOfEmployees ?: "",
    AnnualRevenue: lead?.AnnualRevenue ?: ""
};

public function mapLeadToRow(Lead lead) returns SheetRow|error {
    LeadFieldMap leadMap = getLeadFieldMap(lead);
    map<int|string|decimal|boolean|float> leadMapAsMap = leadMap;
    
    SheetRow row = from string fieldName in fieldMapping
                   select leadMapAsMap.hasKey(fieldName) ? 
                          leadMapAsMap.get(fieldName) : 
                          "";
    
    string[] invalidFields = from string fieldName in fieldMapping
                             where !leadMapAsMap.hasKey(fieldName)
                             select fieldName;
    
    if invalidFields.length() > 0 {
        return error(string `Invalid field name(s) in fieldMapping: ${string:'join(", ", ...invalidFields)}. Supported fields are: ${string:'join(", ", ...leadMapAsMap.keys())}`);
    }
    
    return row;
}
