# Pizza Order Management Agent  

## Description  
This project is developed with the assistance of the Ballerina Copilot feature, with most of the code auto-generated using Copilot. Additionally, it showcases the capabilities of the Ballerina AI agent in enhancing development workflows and intelligent assistance.

## Prerequisites  
- An OpenAI API key  

## Usage Instructions  
1. Navigate to the **Configuration** section in the **Artifacts** window and update the `openAiApiKey` value with your OpenAI API key.  
2. Go to the **environment** folder and run `docker compose up` to set up a MySQL server with the initial database schema and sample data.  
3. Click on **orderManagementAgent**, open the agent window, and click the **Chat** button to start interacting with the agent.  


### Deploy on **Devant**


1. Deploy this integration on **Devant** as an **AI Agent**.
2. Host a MySQL server to store the data for the application.
> **Note:** You can create a MySQL database directly on **Devant**. To do this, navigate to the [**Devant Console**](https://console.devant.dev), select your **Organization**, and then go to the **Databases** section under the **Admin** tab in the left navigation.
3. Run the `environment/init.sql` script in the connected database to initialize the required database structure and configurations.
4. In the **Overview** section of the newly created integration, Configure OpenAI API Key `openAiApiKey` and the configurables for MySQL database under `Default Configurables > admin/pizza` before deploying the AI Agent.
5. Once deployed, click on **"Test"** to start interacting with the agent.
