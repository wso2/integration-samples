A(["Begin"]):::startNode
B["Read from Google Drive"]:::processNode
C["Document Chunking"]:::processNode
D["Embedding Generation"]:::processNode
E["Ingest to Pinecone"]:::processNode
F(["Complete"]):::endNode

A --> B --> C --> D --> E --> F
