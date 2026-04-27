import ballerinax/gcloud.pubsub;

final pubsub:Publisher pubsubPublisher = check new (string `${pubsubTopicName}`, projectId = string `${pubsubProjectId}`, credentials = {credentialsJson: pubsubAuthToken});
