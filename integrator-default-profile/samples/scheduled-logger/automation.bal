import ballerina/io;
import ballerina/time;

public function main() returns error? {
    // Get the current timestamp
    time:Utc currentTime = time:utcNow();
    string formattedTime = time:utcToString(currentTime);

    // Print the timestamp in UTC format
    io:println("Current timestamp: " + formattedTime);
}
