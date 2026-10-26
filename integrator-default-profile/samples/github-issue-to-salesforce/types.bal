// Color-coded labels help you categorize and filter your issues
public type Label record {|
    // Unique identifier for the label
    int id;
    string node_id;
    // URL for the label
    string url;
    // The name of the label
    string name;
    // Optional description of the label, such as its purpose
    string? description;
    // 6-character hex code, without the leading #, identifying the color
    string color;
    // Whether this label comes by default in a new repository
    boolean default;
|};

// Salesforce case record type
public type SalesforceCase record {|
    string Subject;
    string Description;
    string Status;
    string Priority;
    string OwnerId;
    string Type?;
    string GitHub_Issue_URL__c?;
|};
