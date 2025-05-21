# ☁️🎵 Weather-Based Music Recommender

This application suggests Spotify playlists based on the **current weather** at your location. It fetches real-time weather data using [WeatherAPI](https://www.weatherapi.com/) and maps the weather condition to a music **mood**, then retrieves a relevant playlist from the **Spotify Web API**.

📍 GitHub Repo: [https://github.com/anuruddhal/MusicForWeather](https://github.com/anuruddhal/MusicForWeather)

---

## 🚀 Features

- 🌦️ Get real-time weather based on your city
- 🎧 Discover Spotify playlists that match the weather mood
- 🔁 Seamless integration between WeatherAPI and Spotify
- ⚙️ Built using the Ballerina programming language

---

## 🛠️ Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/anuruddhal/MusicForWeather.git
cd MusicForWeather
```

### 2. Prerequisites

- Ballerina installed: [https://ballerina.io/downloads/](https://ballerina.io/downloads/)
- Internet connection
- API keys for WeatherAPI and Spotify (details below)

---

## 🔑 Getting API Keys

### WeatherAPI

1. Visit [https://www.weatherapi.com/](https://www.weatherapi.com/)
2. Sign up for a free account
3. Get your API key from the **Dashboard**
4. Save it in the `Config.toml` file as shown below

### Spotify API

1. Go to [https://developer.spotify.com/dashboard/](https://developer.spotify.com/dashboard/)
2. Create a new application
3. Copy the **Client ID** and **Client Secret**
---

## ⚙️ Configuration

Create a `Config.toml` file in the root directory and add configurations:

```toml
SPOTIFY_CLIENT_ID = ""	# Type of STRING
SPOTIFY_CLIENT_SECRET = ""	# Type of STRING
WEATHER_API_KEY = ""	# Type of STRING

```

---

## 🏗️ Run the Application

```bash
bal run
```

### Available Endpoints

- `GET /MusicMood/playList?location=Colombo`  
  → Returns playlist based on weather on location

---

## 📄 Example Output

```json
{
	"location": "Colombo",
	"weather": "Clear",
	"musicMood": "Happy, Upbeat",
	"playList": [
		{
			"name": "Good Mornings - Happily Positive Music to Start The Day",
			"artist": "Extra Music",
			"url": "https://open.spotify.com/playlist/3IBrsav3Sh8AImtaGoaP07"
		},
		{
			"name": "Upbeat Songs That Everyone Knows",
			"artist": "christianSebastian",
			"url": "https://open.spotify.com/playlist/0t2A2rfRHsYVdAPybNGlUN"
		},
		{
			"name": "Happy Songs 2025 - Good Vibes and Upbeat Music for a Good Mood 😊",
			"artist": "Music-Hits_.",
			"url": "https://open.spotify.com/playlist/7s09coXLGbofhNrwSusr4G"
		},
		{
			"name": "Upbeat Pop Hits 2024",
			"artist": "Lost Records",
			"url": "https://open.spotify.com/playlist/0lU86qLkSQVI991j4BUTDF"
		},
		{
			"name": "Feeling Happy 🙂😃 | Upbeat Dance Hits ",
			"artist": "Be Yourself Music",
			"url": "https://open.spotify.com/playlist/7ppLOUazFvRHKrs44J90M5"
		},
		{
			"name": "ADHD Happy Brain  🧠 Upbeat Mix 2025🔥",
			"artist": "vyllyb",
			"url": "https://open.spotify.com/playlist/0HSwn1caqoTGGG3YpcE9mk"
		},
		{
			"name": "Happy Songs | Feel Good Vibes | Upbeat Party Anthems (Clean)",
			"artist": "Ross Brown",
			"url": "https://open.spotify.com/playlist/6zjDLhUuo0Gw9C1eFUkhMT"
		},
		{
			"name": "Upbeat Instrumental Work Music | Background Happy Energetic Relaxing Music for Working Fast & Focus",
			"artist": "dpperformance",
			"url": "https://open.spotify.com/playlist/2lMEDCAC7MKutdfYyCrSIx"
		},
		{
			"name": "Upbeat Music",
			"artist": "LoudKult",
			"url": "https://open.spotify.com/playlist/0wGRp5fy2whER8XLuAPwJz"
		},
		{
			"name": "Upbeat lofi🎧",
			"artist": "Chill Music",
			"url": "https://open.spotify.com/playlist/3TXzh2DR34M0vbVNUXXUgV"
		},
		{
			"name": "Upbeat Old Songs",
			"artist": "Irene",
			"url": "https://open.spotify.com/playlist/5YGRUh2y9XYouZNVCLs6oB"
		},
		{
			"name": "Upbeat/Happy Workout Music ",
			"artist": "Madeline Sawdye",
			"url": "https://open.spotify.com/playlist/4CZDlbjvY1bvPz7TEtwKpz"
		},
		{
			"name": "Up-beat Hits🎉🌈",
			"artist": "Amie",
			"url": "https://open.spotify.com/playlist/705HKuNKDF3VQPGy6J4BJz"
		}
	]
}
```

---

## 🤖 Built With

- [Ballerina](https://ballerina.io/) – for integration
- [WeatherAPI](https://www.weatherapi.com/) – for weather data
- [Spotify API](https://developer.spotify.com/documentation/web-api/) – for playlist recommendations

---

## 📫 Contact

For questions, suggestions, or contributions, feel free to open an issue or pull request at  
👉 [https://github.com/anuruddhal/MusicForWeather](https://github.com/anuruddhal/MusicForWeather)

Happy hacking! 🎧☀️🌧️