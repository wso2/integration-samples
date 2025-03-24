# Weather-Based Activity Recommender

## Description

This sample combines weather data and AI-powered recommendations to suggest personalized activities based on current weather conditions and user interests. The service fetches real-time weather information, processes it, and uses OpenAI to generate tailored activity recommendations.

## Prerequisites

- Obtain an API key from [OpenWeather API](https://openweathermap.org/api) for weather data access.
- Create an account on [OpenAI](https://openai.com) and obtain an API key for AI recommendations.
- Update the configuration with your API keys, username, city name, and interests.

```toml
openaiApiKey = "YOUR_OPENAI_API_KEY"
weatherApiKey = "YOUR_WEATHER_API_KEY"
cityName = "colombo"
userInterests = ["outdoor activities", "indoor activities", "sports", "entertainment", "cultural events"]
userName = "YOUR_NAME"
```

## Usage Instructions

1. Deploy this integration in **Devant** as a scheduled job.
2. Once deployed, it will fetch weather data, generate activity recommendations, and display the output.

Note: If scheduling this job is not a requirement, you can execute the integration locally using the Run button in Ballerina Integrator.

## How It Works

- The application first fetches weather data from the OpenWeather API using the configured city name.
- It extracts and formats relevant weather information (temperature, condition, description).
- The weather information and user interests are combined into a prompt for the OpenAI API.
- OpenAI generates personalized activity recommendations based on the weather conditions and user preferences.
- The application displays both the weather summary and activity recommendations in a formatted output.

## Example Output

```
===== WEATHER-BASED ACTIVITY RECOMMENDATIONS =====
For: John

Current weather in New York: Clear (clear sky) with temperature of 22.5°C

RECOMMENDED ACTIVITIES:
1. Visit Central Park - The clear sky and pleasant temperature make it perfect for a leisurely walk or picnic in the park.
2. Outdoor Photography - With your interest in photography, this clear weather provides excellent lighting conditions for urban landscape shots.
3. Cycling along the Hudson River - The comfortable temperature and clear conditions are ideal for enjoying a bike ride along the scenic route.
4. Rooftop Dining - Take advantage of the clear evening by enjoying dinner at one of the city's many rooftop restaurants.
5. Street Art Tour - Explore the colorful murals around the city while enjoying the pleasant weather.
===============================================
```
