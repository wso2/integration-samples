import ballerina/ai;

final ai:InMemoryShortTermMemoryStore helpdeskMemoryStore = check new (size = 20);
final ai:ShortTermMemory helpdeskMemory = check new (store = helpdeskMemoryStore);

final ai:Wso2EmbeddingProvider helpdeskEmbeddingProvider = check ai:getDefaultEmbeddingProvider();
final ai:InMemoryVectorStore helpdeskVectorStore = check new ai:InMemoryVectorStore();
final ai:VectorKnowledgeBase helpdeskKnowledgeBase =
        new ai:VectorKnowledgeBase(helpdeskVectorStore, helpdeskEmbeddingProvider, ai:DISABLE);
