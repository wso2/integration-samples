import ballerina/log;
import ballerinax/salesforce.marketingcloud;

public function main() returns error? {
    do {
        marketingcloud:SendEmailMessageResponse marketingcloudSendemailmessageresponse = check marketingcloudClient->sendEmailMessage("{
                        definitionKey : "Welcome_Email_v1",
        recipients:[
        {
            contactKey: "contact-001",
            to: "john.doe@example.com"
        }
        ]
    }
    ") ;
}
 on fail error e{
    log: printError("Error occurred", 'error = e)
;
 return e      ;
}
}
