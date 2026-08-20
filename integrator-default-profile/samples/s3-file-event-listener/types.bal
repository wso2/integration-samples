
type S3EventRecord record {
    string eventSource;
    string eventName;
    string eventTime;
    string awsRegion;
    record {
        record {string name; string arn;} bucket;
        record {string key; int size; string eTag;} 'object;
    } s3;
};

type S3Notification record {
    S3EventRecord[] Records;
};
