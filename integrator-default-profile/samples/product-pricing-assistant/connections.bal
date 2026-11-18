import ballerina/ai;
import ballerinax/stripe;

final ai:Wso2EmbeddingProvider productCatalogEmbeddingProvider = check ai:getDefaultEmbeddingProvider();
final ai:InMemoryVectorStore productCatalogVectorStore = check new ai:InMemoryVectorStore();
final ai:VectorKnowledgeBase productCatalogKnowledgeBase =
        new ai:VectorKnowledgeBase(productCatalogVectorStore, productCatalogEmbeddingProvider);

configurable string stripeSecretKey = ?;

final stripe:Client stripeClient = check new ({
    auth: {token: stripeSecretKey}
});
