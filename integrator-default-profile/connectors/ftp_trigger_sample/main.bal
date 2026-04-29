import ballerina/ftp;
import ballerina/log;

listener ftp:Listener ftpListener = new (protocol = ftp:FTP, host = string `${ftpHost}127.0.0.1`, auth = {credentials: {username: string `${ftpUsername}default`, password: string `${ftpPassword}default`}}, port = ftpPort21);

@ftp:ServiceConfig {
    path: string `${ftpPath}/`
}
service on ftpListener {
    @ftp:FunctionConfig {
        afterProcess: {
            moveTo: string `/tmp/success`
        },
        afterError: {
            moveTo: string `/tmp/error`
        }
    }
    remote function onFileCsv(string[][] content, ftp:FileInfo fileInfo) returns error? {
        do {
            log:printInfo(fileInfo.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
