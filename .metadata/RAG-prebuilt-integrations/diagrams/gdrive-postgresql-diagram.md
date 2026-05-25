A(["Begin"]):::startNode
B["Read from Google Drive"]:::processNode
C["Document Chunking"]:::processNode
D["Embedding Generation"]:::processNode
E["Ingest to PostgreSQL"]:::processNode
f(["Complete"]):::endNode

A --> B --> C --> D --> E --> F
