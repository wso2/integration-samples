import ballerina/ftp;
import ballerinax/kafka;

listener ftp:Listener ftpListener = new (
    host = ftpHost,
    port = ftpPort,
    path = "/timesheets/incoming/",
    auth = {
        credentials: {username: ftpUser, password: ftpPassword}
    },
    fileNamePattern = "*.csv"
);

string[] validContractorIds = ["CTR-001", "CTR-002", "CTR-003", "CTR-004", "CTR-005"];

final kafka:Producer kafkaProducer = check new (kafkaBootstrapServers);

service ftp:Service on ftpListener {

    remote function onFileCsv(TimesheetRecord[] timesheets, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {
        if timesheets.length() != 150 {
            check caller->move(fileInfo.pathDecoded, "/timesheets/quarantine/" + fileInfo.name);
            return;
        }

        int invalidCount = 0;
        foreach TimesheetRecord item in timesheets {
            if validContractorIds.indexOf(item.contractor_id) is () {
                invalidCount += 1;
            }
        }

        float invalidPercentage = (<float>invalidCount / <float>timesheets.length()) * 100.0;
        if invalidPercentage > 5.0 {
            check caller->move(fileInfo.pathDecoded, "/timesheets/quarantine/" + fileInfo.name);
            return;
        }

        foreach TimesheetRecord item in timesheets {
            check kafkaProducer->send({value: item, topic: kafkaTopic});
        }

        check caller->rename(fileInfo.pathDecoded, "/timesheets/processed/" + fileInfo.name);
    }
}
