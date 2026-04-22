import ballerina/log;
import ballerinax/hubspot.crm.extensions.videoconferencing;

public function main() returns error? {
    do {
        videoconferencing:ExternalSettings videoconferencingExternalsettings = check videoconferencingClient->/[<int:Signed32>hubspotVideoconfAppId].get();
        log:printInfo(videoconferencingExternalsettings.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
