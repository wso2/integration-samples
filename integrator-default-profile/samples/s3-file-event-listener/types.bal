
public type Bucket record {|
    string name;
    string arn;
|};

public type Object record {|
    string 'key;
    int size;
    string eTag;
|};

public type S3 record {|
    Bucket bucket;
    Object 'object;
|};

public type S3EventRecord record {|
    string eventSource;
    string eventName;
    string eventTime;
    string awsRegion;
    S3 s3;
|};

type S3Notification record {|
    S3EventRecord[] events;
|};
