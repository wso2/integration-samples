import ballerina/ai;
import ballerinax/shopify.admin;

final ai:Wso2EmbeddingProvider returnPolicyEmbeddingProvider = check ai:getDefaultEmbeddingProvider();
final ai:InMemoryVectorStore returnPolicyVectorStore = check new ai:InMemoryVectorStore();
final ai:VectorKnowledgeBase returnPolicyKnowledgeBase =
        new ai:VectorKnowledgeBase(returnPolicyVectorStore, returnPolicyEmbeddingProvider);

configurable string shopifyAccessToken = ?;
configurable string shopifyStoreServiceUrl = ?;

final admin:Client shopifyClient = check new (
    {xShopifyAccessToken: shopifyAccessToken},
    shopifyStoreServiceUrl
);
