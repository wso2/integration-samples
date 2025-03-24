# Math Tutor

## Description

An AI-powered math tutor that uses Azure OpenAI's GPT models to assist with specific mathematical operations. This sample demonstrates how to integrate Ballerina with Azure OpenAI services and implement agent tools for three mathematical operations: sum, multiply, and square root.

## Prerequisites

- Obtain an Azure OpenAI service account with API access
- Configure a GPT-4o deployment in your Azure OpenAI resource

## Usage Instructions

1. Configure your Azure OpenAI credentials in the `Config.toml` file:
   - `apiKey` - Your Azure OpenAI API key
   - `deploymentId` - Your GPT model deployment ID
   - `apiVersion` - API version
   - `serviceUrl` - Your Azure OpenAI endpoint URL
2. Run the Ballerina application to start the math tutoring service.
3. Enter your math problems involving addition, multiplication, or square roots.
4. The AI tutor will use the appropriate agent tools to solve the problem.
5. To expose your AI agent through API endpoints and integrate it within your applications, deploy this integration as an AI agent in **Devant**.

## How It Works

- The application connects to Azure OpenAI services using the provided credentials
- It implements three agent tools:
  - **sum**: Adds two or more numbers together
  - **multiply**: Multiplies two or more numbers
  - **sqrt**: Calculates the square root of a number
- The AI model determines which tool to use based on the user's query.
