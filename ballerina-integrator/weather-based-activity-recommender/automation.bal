public function main() returns error? {
    do {
        // Get weather data
        json weatherData = check getWeatherData();

        // Extract relevant weather information
        string weatherSummary = check generateWeatherSummary(weatherData);

        // Generate activity recommendations using OpenAI connector
        string? recommendations = check generateAIRecommendations(weatherSummary);

        // Print the recommendations
        showActivityInfo(weatherSummary, recommendations);
    } on fail error e {
        return error("Failed to generate activity recommendations: " + e.message());
    }
}
