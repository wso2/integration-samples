import ballerinax/milvus;

final milvus:Client milvusClient = check new (string `${milvusServiceUrl}`, authConfig = {token: milvusToken});
