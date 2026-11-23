# Path to the Markdown file with the company's contract playbook. The integration loads it into the knowledge base when it starts.
configurable string playbookPath = "contract-playbook.md";
# API key for the OpenAI platform. The agent uses OpenAI for the model and for the playbook embeddings.
configurable string openAiApiKey = ?;
