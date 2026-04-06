# Weather-Based Music Recommender

## Description
This application suggests Spotify playlists based on the **current weather** at your location. It fetches real-time weather data using [WeatherAPI](https://www.weatherapi.com/) and maps the weather condition to a music **mood**, then retrieves a relevant playlist from the **Spotify Web API**.


## Prerequisites
- Weather API key
- Spotify **Client ID** and **Client Secret**

## Getting API Keys

### WeatherAPI

1. Visit [https://www.weatherapi.com/](https://www.weatherapi.com/)
2. Sign up for a free account
3. Get your API key from the **Dashboard**
4. Save it in the `Config.toml` file as shown below

### Spotify API

1. Go to [https://developer.spotify.com/dashboard/](https://developer.spotify.com/dashboard/)
2. Create a new application
3. Copy the **Client ID** and **Client Secret**


## Usage Instructions
1. Navigate to the **Configuration** section in the **Artifacts** window and update the configuration values with your API keys.

```toml
SPOTIFY_CLIENT_ID = ""	# Type of STRING
SPOTIFY_CLIENT_SECRET = ""	# Type of STRING
WEATHER_API_KEY = ""	# Type of STRING

```

2. Run the integration locally using the **Run** button in WSO2 Integrator.

2. Use the **"Try It"** feature (auto popup) to send a request.

## Deploy on **WSO2 Cloud**

1. Use the **Deployment Options** to deploy this integration on **WSO2 Cloud** as an **Integration as API**.
2. Click **Deploy** and follow the instructions.
