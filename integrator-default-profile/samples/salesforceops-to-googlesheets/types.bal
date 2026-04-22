
type Attributes record {|
    string? 'type;
    string? url;
|};

type Opportunity record {
    Attributes attributes;
    string? Id;
    string? AccountId;
    string? OwnerId;
    string? Name;
    string? StageName;
    decimal? Amount;
    decimal? Probability;
    decimal? ExpectedRevenue;
    string? CloseDate;
    string? Type;
    string? LeadSource;
    string? Description;
    string? ContactId;
    string? CampaignId;
    string? Pricebook2Id;
    string? NextStep;
    decimal? TotalOpportunityQuantity;
    boolean? IsClosed;
    boolean? IsWon;
    boolean? IsDeleted;
    boolean? IsPrivate;
    string? ForecastCategory;
    string? ForecastCategoryName;
    boolean? HasOpportunityLineItem;
    boolean? HasOpenActivity;
    boolean? HasOverdueTask;
    int? PushCount;
    int? FiscalYear;
    int? FiscalQuarter;
    string? Fiscal;
    string? LastStageChangeDate;
    string? LastActivityDate;
    string? LastAmountChangedHistoryId;
    string? LastCloseDateChangedHistoryId;
    string? CreatedDate;
    string? CreatedById;
    string? LastModifiedDate;
    string? LastModifiedById;
    string? LastViewedDate;
    string? LastReferencedDate;
};

type SheetRow (int|string|decimal|boolean|float)[];
