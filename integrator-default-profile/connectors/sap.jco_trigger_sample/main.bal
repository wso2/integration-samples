import ballerina/log;
import ballerinax/sap.jco;

listener jco:Listener jcoListener = new (<jco:ServerConfig>{gwhost: string `${gwHost}`, gwserv: string `${gwService}`, progid: string `${progId}`, repositoryDestination: {ashost: string `${sapAshost}`, sysnr: string `${sapSysnr}`, jcoClient: string `${sapJcoClientNum}`, user: string `${sapUsername}`, passwd: string `${sapPassword}`}});

service jco:IDocService on jcoListener {
    remote function onReceive(xml iDoc) returns error? {
        log:printInfo("Received IDoc: " + iDoc.toString());
    }

    remote function onError(error err) returns error? {
        log:printError("Error processing IDoc", err);
    }
}
