import ballerinax/sap.businessone.banking;

final banking:Client bankingClient = check new ({
    companyDb: "",
    username: "",
    password: ""
});

