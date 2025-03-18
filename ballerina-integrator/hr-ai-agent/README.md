# AI Chat Agent for HR Information

## Description

This AI-powered chat agent provides assistance with HR-related inquiries by referencing company-specific HR policies. It ensures employees can easily access relevant policy information in a conversational manner.

## Usage Instructions

This implementation utilizes Pinecone as the vector database and OpenAI for embedding models. The data is processed and fed into the vector store using the Devant RAG data ingestion feature. Devant provides a robust platform for efficiently managing and structuring unstructured documents for Retrieval-Augmented Generation (RAG).

To integrate your company's HR policies into the system, simply feed them into the vector store within Pinecone using Devant's ingestion tools.

## Ingest HR Policies data to the vector store

### Step 1: Initialize Vector Store

Large Language Models (LLMs) process contextual information as numerical vectors (embeddings). A vector database efficiently stores these embeddings for quick retrieval. Devant supports various vector databases such as Pinecone, Weaviate, and Chroma.

1. Select `Pinecone` as the vector database.

2. Enter the API key in the `API Key` field.
    To create an API key, refer to the [Pinecone API Key documentation](https://docs.pinecone.io/guides/projects/manage-api-keys#create-an-api-key).

3. Enter the `Collection Name`. If the collection does not exist, it will be created automatically.

4. Click Next.

### Step 2: Configure the Embedding Model

1. Select `text-embedding-ada-002` from the OpenAI embedding model dropdown.

2. Enter the API key in the `Embedding Model API Key` field.
    To create an API key, refer to the [OpenAI Platform documentation](https://platform.openai.com/docs/guides/embeddings).

3. Click Next.

### Step 3: Configure Chunking

Chunking helps break large documents into smaller, manageable sections for efficient processing.
Chunking strategy, Max segment size, and Max overlap size are pre-filled with default values but can be modified as needed.

    - Chunking strategy: Defines how text is split into smaller, manageable pieces (chunks).
    - Max segment size: Determines the maximum length of tokens for each chunk.
    - Max overlap size: Defines how many tokens repeat between consecutive chunks.

### Step 4: Upload Source Files

Next, upload your source files (e.g., PDFs, CSVs, or text documents) for processing.

1. Click Select Files to open your file explorer.
2. Choose the files you want to upload.
3. Click Upload. When you click **Upload** it will generate embeddings for the uploaded files and store them in the vector database.

## Deploy the agent in Devant

1. Deploy this integration in Devant as an AI Agent.
2. After deployment, set up the configuration by adding the OpenAI embedding token as `OPENAI_TOKEN`, the Pinecone API key as `PINECONE_API_KEY`, and the Pinecone collection URL as `PINECONE_URL`.
3. Navigate to the Test section in the left-side menu and select Agent Chat.
4. Start interacting with the chat Agent through the chat interface.
