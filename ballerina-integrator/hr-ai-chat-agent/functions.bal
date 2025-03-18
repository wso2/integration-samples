import ballerinax/openai.chat;
import ballerinax/openai.embeddings;
import ballerinax/pinecone.vector;

embeddings:Client embeddingsClient = check new ({
    auth: {
        token: OPENAI_TOKEN
    }
});

final vector:Client pineconeVectorClient = check new ({
    apiKey: PINECONE_API_KEY
}, serviceUrl = PINECONE_URL);

final chat:Client openAIChat = check new({
    auth: {
        token: OPENAI_TOKEN
    }
});

final string embedding = "text-embed";

vector:QueryRequest queryRequest = {
    topK: 4,
    includeMetadata: true
};

public type Metadata record {
    string text;
};

public type ChatResponseChoice record {|
    chat:ChatCompletionResponseMessage message?;
    int index?;
    string finish_reason?;
    anydata...;
|};

function llmChat(string query) returns string|error {
    float[] embeddingsFloat = check getEmbeddings(query);
    queryRequest.vector = embeddingsFloat;
    vector:QueryMatch[] matches = check retrieveData(queryRequest);
    string context = check augment(matches);
    string chatResponse = check generateText(query, context);
    return chatResponse;
}

function getEmbeddings(string query) returns float[]|error {
    embeddings:CreateEmbeddingRequest req = {
        model: "text-embedding-ada-002",
        input: query
    };
    embeddings:CreateEmbeddingResponse embeddingsResult = check embeddingsClient->/embeddings.post(req);

    float[] embeddings = embeddingsResult.data[0].embedding;
    return embeddings;
}

isolated function retrieveData(vector:QueryRequest queryRequest) returns vector:QueryMatch[]|error {
    vector:QueryResponse response = check pineconeVectorClient->/query.post(queryRequest);
    vector:QueryMatch[]? matches = response.matches;
    if (matches == null) {
        return error("No matches found");
    }
    return matches;
}

isolated function augment(vector:QueryMatch[] matches) returns string|error {
    string context = "";
    foreach vector:QueryMatch data in matches {
        Metadata metadata = check data.metadata.cloneWithType();
        context = context.concat(metadata.text);
    }
    return context;
}

isolated function generateText(string query, string context) returns string|error {
    string systemPrompt = string `You are an HR Policy Assistant that provides employees with accurate answers
        based on company HR policies.Your responses must be clear and strictly based on the provided context.
        ${context}`;

    chat:CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [{
            "role": "system",
            "content": systemPrompt
        },
        {
            "role": "user",
            "content": query
        }
        ]
    };

    chat:CreateChatCompletionResponse chatResult = 
        check openAIChat->/chat/completions.post(request);
    ChatResponseChoice[] choices = check chatResult.choices.ensureType();
    string? chatResponse = choices[0].message?.content;

    if (chatResponse == null) {
        return error("No chat response found");
    }
    return chatResponse;
}
