# Currency Converter API

## Description

A REST API that converts currency from one unit to another using an external exchange rate API. The service also caches
exchange rates using Redis to improve performance and reduce external API calls.

## Prerequisites

- Ensure that Redis is running on `localhost:6379`. (If Redis is running on a different host or port, update the Redis
  configurations in the implementation accordingly.)
  Note: If the Redis server is not running, the service will still work, but without caching.

- Log in to [ExchangeRate API](https://www.exchangerate-api.com/) and obtain an API key.
- Update the `apiKey` configuration in the `Config.toml` file with the obtained API key.

## Usage Instructions

1. Run the integration locally using the **Run** button in Ballerina Integrator.
2. Use the **"Try It"** feature (auto popup) to send a `GET` request to the `/convert` endpoint with the following query
   parameters:
    - `from` (default: `USD`): The source currency.
    - `to` (default: `LKR`): The target currency.
    - `amount` (default: `1`): The amount to be converted.

### Deploy on **Devant**

1. Deploy this integration on **Devant** as an **Integration as API**.
2. Configure ExchangeRate API `apiKey`, and `redisConnectionString` before running the integration.
3. Once deployed, click on **"Test"** to try out the API.

## How It Works

- The service listens on port `9090` for incoming HTTP requests.
- When a request is received, the service first checks the Redis cache for the exchange rate.
- If the exchange rate is not found in the cache, the service calls the external exchange rate API to get the exchange
  rate.
- The service then calculates the converted amount and returns it to the client.
- The service caches the exchange rate in Redis for future requests.

## Example Request

```
GET /convert?from=EUR&to=INR&amount=100
```

## Example Response

```json
{
  "value": 8500.50
}
```
