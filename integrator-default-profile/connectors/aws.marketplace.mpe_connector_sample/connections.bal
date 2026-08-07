import ballerinax/aws.marketplace.mpe;

final mpe:Client mpeClient = check new ({
    auth: {
        accessKeyId,
        secretAccessKey
    },
    region
});
