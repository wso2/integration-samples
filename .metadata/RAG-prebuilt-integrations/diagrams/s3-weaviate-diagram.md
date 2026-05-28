A(["Begin"]):::startNode
B["Fetch from AWS S3"]:::processNode
C["Document Chunking"]:::processNode
D["Embedding Generation"]:::processNode
E["Ingest to Weaviate"]:::processNode
F(["Complete"]):::endNode

A --> B --> C --> D --> E --> F
