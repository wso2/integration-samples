import ballerina/ai;

final ai:Wso2EmbeddingProvider returnPolicyEmbeddingProvider = check ai:getDefaultEmbeddingProvider();
final ai:InMemoryVectorStore returnPolicyVectorStore = check new ai:InMemoryVectorStore();
final ai:VectorKnowledgeBase returnPolicyKnowledgeBase =
        new ai:VectorKnowledgeBase(returnPolicyVectorStore, returnPolicyEmbeddingProvider);
