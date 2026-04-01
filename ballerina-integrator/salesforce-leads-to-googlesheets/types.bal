public type Attributes record {|
    string? 'type;
    string? url;
|};

public type Lead record {
    Attributes? attributes?;
    string? Id?;
    string? FirstName?;
    string? LastName?;
    string? Email?;
    string? Phone?;
    string? Company?;
    string? Title?;
    string? Status?;
    string? LeadSource?;
    string? Industry?;
    string? Rating?;
    string? OwnerId?;
    string? Description?;
    string? Website?;
    string? Country?;
    string? City?;
    string? State?;
    boolean? IsConverted?;
    string? ConvertedDate?;
    string? CreatedDate?;
    string? LastModifiedDate?;
    string? LastActivityDate?;
    int? NumberOfEmployees?;
    decimal? AnnualRevenue?;
};

type SheetRow (int|string|decimal|boolean|float)[];

public type SalesforceConfig record {|
    string refreshToken;
    string clientId;
    string clientSecret;
    string refreshUrl;
    string baseUrl;
|};

public type GoogleConfig record {|
    string refreshToken;
    string clientId;
    string clientSecret;
|};
