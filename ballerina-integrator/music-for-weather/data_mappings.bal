function transform(WeatherData weatherData, SpotifyPlayList spotifyData) returns MusicSuggestion => {
    location: weatherData.location.name,
    weather: weatherData.current.condition.text,
    musicMood: getMusicMoodForWeather(weatherData.current.condition.code),
    playlist: from var itemsItem in spotifyData.playlists.items
        where itemsItem is ItemsItem 
        let string name = itemsItem.name,
            string url = itemsItem.external_urls.spotify,
            string artist = itemsItem.owner.display_name
        where name != "" && url != "" && artist != ""
        select {
            name,
            url,
            artist
        }
};
