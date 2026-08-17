import ballerina/random;

function generateTicketId() returns string {
    int randomNum = checkpanic random:createIntInRange(100000, 999999);
    return string `SRV-${randomNum}`;
}
