import ballerinax/sap.successfactors.employeecentralec;

final employeecentralec:Client employeecentralecClient = check new ({auth: {username: userName, password: password}}, hostname);
