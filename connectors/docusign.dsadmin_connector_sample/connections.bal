import ballerinax/docusign.dsadmin;

final dsadmin:Client dsadminClient = check new (string `${docusignServiceUrl}`, auth = {token: docusignBearerToken});
