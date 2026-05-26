## What it does
- This RAG ingestion integration automatically ingests files from Amazon S3 and generates embeddings, storing them in your Pinecone vector database. These embeddings enable semantic search and retrieval for your RAG applications.

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

#### Pinecone

- Create Pinecone Account:
	- Go to [Pinecone.io](https://www.pinecone.io/) and sign up
	- Create a new project if you don't already have one
	- Navigate to the **API Keys** section in the left sidebar menu
- Get API Key:
	- Click the **Create API Key** button
	- From the Pinecone console, copy your API key and store it
	- Enter the name of your collection, can be existing one or a new one gets created

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
