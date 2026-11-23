import ballerina/ai;
import ballerinax/ai.openai;

final openai:ModelProvider openAiModel = check new (openAiApiKey, "gpt-4.1");
final openai:EmbeddingProvider openAiEmbeddingProvider = check new (openAiApiKey, "text-embedding-3-small");
final ai:InMemoryVectorStore playbookVectorStore = check new ();
final ai:VectorKnowledgeBase playbookKnowledgeBase = new (playbookVectorStore, openAiEmbeddingProvider, ai:AUTO);
