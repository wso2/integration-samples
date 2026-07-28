# Event-Driven Social Media Backend

A Twitter-style social media backend built with WSO2 Integrator. A `POST` flows from a REST API through a sentiment check into MySQL, then out to Slack via a RabbitMQ event pipeline. Built as three integrations in one project.

## Integrations

| Module | Type | Responsibility |
| --- | --- | --- |
| `social_media` | HTTP service | Users and posts REST API. Screens posts for sentiment, persists to MySQL, and publishes a new-post event to RabbitMQ. |
| `sentiment_api` | HTTP service | Scores post text as positive, negative, or neutral. |
| `post_notifier` | RabbitMQ event integration | Consumes new-post events and posts to Slack. |

## Prerequisites

- [WSO2 Integrator](https://wso2.com/integrator/)
- A running **MySQL** instance (`social_media` database)
- A running **RabbitMQ** broker
- A **Slack** app with a bot token

## Run

1. Open the project in WSO2 Integrator and set the MySQL, RabbitMQ, and Slack configurables.
2. Run the project, then `POST` a new post to the Social Media API.
3. Accepted posts are stored in MySQL and announced in your Slack channel.

> Full walkthrough: **Build an Event-Driven Social Media Backend** in the WSO2 Integrator tutorials.
