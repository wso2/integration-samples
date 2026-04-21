import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /MusicMood on httpDefaultListener {
    resource function get playlist(string location) returns error|json|http:InternalServerError {
        do {
            WeatherData weatherResponse = check weatherAPIClient->get(string `/current.json?q=${location}&key=${WEATHER_API_KEY}`);
            int weatherCode = weatherResponse.current.condition.code;
            string musicMood = getMusicMoodForWeather(weatherCode);
            SpotifyPlayList spotifyResponse = check spotifyClient->get(string `/search?q=${musicMood}&type=playlist`);

            return transform(weatherResponse, spotifyResponse);
        } on fail error err {
            return error("unhandled error", err);
        }
    }
}
