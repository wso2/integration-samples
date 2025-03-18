public function main() returns error? {
    // Get weather data
    json weatherData = check getWeatherData();

    // Extract relevant weather information
    string weatherSummary = generateWeatherSummary(weatherData);

    // Generate activity recommendations using OpenAI connector
    string? recommendations = check generateAIRecommendations(weatherSummary);

    // Print the recommendations
    showActivityInfo(weatherSummary, recommendations);
}
