# Stock Price Data Manager

## Description

This integration retrieves a daily summary of stock price data from a public API and uploads it to an FTP server in CSV format. It is intended to run automatically at a scheduled time each day, supporting the long-term collection of financial data for analysis and reporting.

## Prerequisites
- Set up an FTP server and obtain the following credentials:
    - host
    - username
    - password
    - port

## Usage Instructions
- Configure `ftpHost`, `ftpUsername`, `ftpPassword`, and `ftpPort` configurations before running the integration.
- Run the integration locally using the **Run** button in Ballerina Integrator.

## Deploy on **Devant**

1. Deploy this integration on **Devant** as an **Automation**.
2. Configure the FTP server credentials (`ftpHost`, `ftpUsername`, `ftpPassword`, and `ftpPort`) before running the **Automation**.
2. Once deployed, it will automatically fetch the stock price data daily at the specified time and upload it to the FTP server.

## How It Works
- The integration calls a public API to fetch the daily stock market summary, including:
    - Top gainers
    - Top losers
- The received JSON response is processed and transformed into CSV format.
- The resulting CSV file is then uploaded to the FTP server using the provided credentials.
