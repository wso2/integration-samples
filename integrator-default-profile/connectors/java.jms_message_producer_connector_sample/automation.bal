import ballerina/log;


public function main() returns error? {
   do {
       check jmsMessageproducer->send({"content": "Hello from WSO2 Integrator!"});
       log:printInfo("Message sent successfully!");
   } on fail error e {
       log:printError("Error occurred", 'error = e);
       return e;
   }
}
