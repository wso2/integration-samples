# Supplier Order Ingestion Hub

A B2B file-integration hub built with WSO2 Integrator for **FreshMart**. Suppliers drop order files in two different formats — Greenfield uploads CSV, Harbor uploads XML — onto an FTP server. The integration normalizes both into one canonical `Order` with the data mapper, stores them in MySQL, archives the files, and emails a daily summary. Built as two integrations in one project.

## Integrations

| Module | Type | Responsibility |
| --- | --- | --- |
| `order_intake` | FTP file integration | One listener, two services: maps Greenfield CSV (`/greenfield`) and Harbor XML (`/harbor`) to the canonical `Order`, persists to MySQL, and archives each file to `/processed` or `/errors`. |
| `daily_summary` | Automation | A scheduled job that reads the day's orders from MySQL, builds an HTML summary, and emails it to procurement. |

## Prerequisites

- [WSO2 Integrator](https://wso2.com/integrator/)
- An **FTP/SFTP** server with `/greenfield`, `/harbor`, `/processed`, and `/errors` directories
- A running **MySQL** instance for the order book
- **SMTP** credentials for the daily summary email

## Run

1. Open the project in WSO2 Integrator and set the FTP, MySQL, and email configurables.
2. Run the project and drop a supplier order file (with its `.ok` marker) into `/greenfield` or `/harbor`.
3. Orders land in MySQL; the scheduled `daily_summary` job emails the day's report to procurement.

> Full walkthrough: **Build a Supplier Order Ingestion Hub** in the WSO2 Integrator tutorials.
