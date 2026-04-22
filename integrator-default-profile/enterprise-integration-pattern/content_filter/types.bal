type DetailedReimbursementTemplate record {
    string reimbursementTypeID;
    string reimbursementTypeName;
    float fixedAmount;
};

type ReimbursementTemplate record {
    string reimbursementTypeID;
    float fixedAmount;
};

type Reimbursement record {
    string id;
    record {
        string reimbursementTypeID;
        float fixedAmount;
    }[] reimbursementTemplates;
};
