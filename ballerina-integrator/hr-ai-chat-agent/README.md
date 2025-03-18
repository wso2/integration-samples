# AI Chat Agent for HR Information

## Description

This AI-powered chat agent provides assistance with HR-related inquiries by referencing company-specific HR policies. It ensures employees can easily access relevant policy information in a conversational manner. 

This implementation utilizes Pinecone as the vector database and OpenAI for embeddings model. Data is processed and ingested into the vector store using Devant’s RAG data ingestion feature, which streamlines the management and structuring of unstructured documents for Retrieval-Augmented Generation (RAG).

## Usage Instructions

To integrate your company's HR policies, simply use Devant’s ingestion tools to feed them into the Pinecone vector store.

## Ingest HR Policies data to the vector store

### Step 1: Initialize Vector Store

Large Language Models (LLMs) process contextual information as numerical vectors (embeddings), which are efficiently stored in a vector database for fast retrieval. Devant supports multiple vector databases, including Pinecone, Weaviate, and Chroma, enabling flexible and efficient embedding management.

1. Select `Pinecone` as the vector database.

2. Enter the API key in the `API Key` field.
    To create an API key, follow the steps in the [Pinecone API Key documentation](https://docs.pinecone.io/guides/projects/manage-api-keys#create-an-api-key).

3. Enter the `Collection Name`. If the collection does not exist, it will be created automatically.

4. Click Next.

### Step 2: Configure the Embedding Model

1. Select `text-embedding-ada-002` from the OpenAI embedding model dropdown.

2. Enter the API key in the `Embedding Model API Key` field.
    To generate an API key, follow the steps in the [OpenAI Platform documentation](https://platform.openai.com/docs/guides/embeddings).

3. Click Next.

### Step 3: Configure Chunking

Chunking breaks large documents into smaller, manageable sections for efficient processing.

The Chunking Strategy, Max Segment Size, and Max Overlap Size are pre-filled with default values but can be adjusted as needed.

    - Chunking strategy: Defines how text is split into smaller, manageable pieces (chunks).
    - Max segment size: Determines the maximum length of tokens for each chunk.
    - Max overlap size: Defines how many tokens repeat between consecutive chunks.

### Step 4: Upload Source Files

Next, upload your source files (e.g., PDFs, CSVs, or text documents) for processing.

1. Click `Select Files` to open your file explorer.
2. Choose the files you want to upload.
3. Click `Upload`. When you click `Upload` it will generate embeddings for the uploaded files and store them in the vector database.

## Deploy the chat agent in Devant

1. Deploy this integration in Devant as an AI Agent.
2. After deployment, set up the configuration by adding the OpenAI embedding token as `OPENAI_TOKEN`, the Pinecone API key as `PINECONE_API_KEY`, and the Pinecone collection URL as `PINECONE_URL`.
3. Start interacting with the AI chat Agent through the chat interface.
