import ballerina/grpc;

final grpc:Client grpcClient = check new (string `${grpcServiceUrl}`);
