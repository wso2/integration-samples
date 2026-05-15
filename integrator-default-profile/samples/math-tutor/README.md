# Math Tutor

## Description

An AI-powered math tutor that uses the WSO2 default model provider to assist with mathematical operations. This sample demonstrates how to build an AI agent in WSO2 Integrator using agent tools for four mathematical operations: sum, subtract, multiply, and divide.

## Prerequisites

- Deploy this integration as an AI agent in **WSO2 Cloud** to obtain access to the default model provider, or configure your own model provider.

## Configuring the Default Model Provider

To set up the default model provider, manually run `Ballerina: Configure default WSO2 model provider` from the Command Palette (Cmd+Shift+P / Ctrl+Shift+P). Sign in with your WSO2 account when prompted, and WSO2 Integrator wires the configuration into your project automatically.

> **Note:** The access token expires after a few hours. If requests to the default model provider start failing, rerun `Ballerina: Configure default WSO2 model provider` from the Command Palette to refresh the token.

## Usage Instructions

1. Run the integration to start the math tutoring service.
2. Enter your math problems involving addition, subtraction, multiplication, or division.
3. The AI tutor will use the appropriate agent tools to solve the problem.
4. To expose your AI agent through API endpoints and integrate it within your applications, deploy this integration as an AI agent in **WSO2 Cloud**.

## How It Works

- The application connects to the WSO2 default model provider.
- It implements four agent tools:
  - **sumTool**: Adds two numbers together
  - **subtractTool**: Subtracts the second number from the first
  - **multTool**: Multiplies two numbers
  - **divideTool**: Divides the first number by the second
- The AI model determines which tool to use based on the user's query.
