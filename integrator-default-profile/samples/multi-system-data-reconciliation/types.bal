
public type Customer record {|
    string email;
    string firstName;
    string lastName;
    string phone;
    string address;
|};

public type FieldMismatch record {|
    string fieldName;
    string salesforceValue;
    string databaseValue;
|};

public type Discrepancy record {|
    string email;
    string discrepancyType;
    FieldMismatch[] fieldMismatches;
|};

public type ReconciliationReport record {|
    string generatedAt;
    int totalSalesforceRecords;
    int totalDatabaseRecords;
    int matchedRecords;
    int mismatchedRecords;
    int missingInDatabase;
    int missingInSalesforce;
    Discrepancy[] discrepancies;
|};
