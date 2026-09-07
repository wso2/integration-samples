import ballerinax/aws.redshiftdata;

final redshiftdata:Client redshiftdataClient = check new (auth = {accessKeyId: accessKeyId, secretAccessKey: secretAccessKey}, region = region, dbAccessConfig = {id: clusterId, database: databaseName});
