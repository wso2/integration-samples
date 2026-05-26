## What it does
- This RAG ingestion integration automatically ingests files from Amazon S3 and generates embeddings, storing them in your Chroma vector database. These embeddings enable semantic search and retrieval for your RAG applications.

<details>

<summary>Data Source Setup</summary>

#### Amazon S3

- Set up AWS credentials:
	- Log in to AWS Management Console
	- Navigate to **IAM** > **Users**
	- Create a new user with S3 access
	- Generate Access Key ID and Secret Access Key
	- Save these credentials securely
- Configure S3 Bucket:
	- Create or select an S3 bucket
	- Note the bucket name
	- Ensure the IAM user has read access to the bucket

</details>

<details>
<summary>Vector Database Setup</summary>

#### Chroma

- Deploy Chroma:
	- Run Chroma server (Docker or standalone)
	- Note your Chroma host and port (default: localhost:8000)
- Collection Setup:
	- Define a collection name for your embeddings

</details>


<details>
<summary>Embedding Model Setup</summary>

#### OpenAI

- Go to OpenAI platform and login to your account
- In the left sidebar, click on **API keys**
- Click the **Create secret key** button
- Copy the key and store it securely

#### Mistral AI

- Go to Mistral AI console
- Go to the API Keys section from the left-hand navigation bar
- Copy it and store it securely

#### Azure OpenAI

- Go to Azure OpenAI Service
- Go to the Keys and Endpoint section located in the left-hand navigation menu under **Resource Management**
- You will see two keys (KEY 1 and KEY 2). You can use either one. Copy the key and store it securely
- Base URL (Endpoint): The Endpoint URL will be displayed here, typically in the format `https://<your-resource-name>.openai.azure.com/`

</details>
