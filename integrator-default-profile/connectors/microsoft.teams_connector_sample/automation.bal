import ballerina/log;
import ballerinax/microsoft.teams;

public function main() returns error? {
    do {
        teams:ChannelCollectionResponse channelList = check teamsClient->listChannels(teamId);
        log:printInfo(channelList.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
