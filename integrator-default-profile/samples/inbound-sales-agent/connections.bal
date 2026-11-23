import ballerina/ai;
import ballerinax/googleapis.gmail;
import ballerinax/salesforce;

final gmail:Client gmailClient = check new ({
    auth: {
        clientId: gmailClientId,
        clientSecret: gmailClientSecret,
        refreshToken: gmailRefreshToken
    }
});

final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        tokenUrl: salesforceTokenUrl,
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret
    }
});

final ai:Wso2EmbeddingProvider productDocsEmbeddingProvider = check ai:getDefaultEmbeddingProvider();
final ai:InMemoryVectorStore productDocsVectorStore = check new ai:InMemoryVectorStore();
final ai:VectorKnowledgeBase productDocsKnowledgeBase =
        new ai:VectorKnowledgeBase(productDocsVectorStore, productDocsEmbeddingProvider);
