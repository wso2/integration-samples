const SUMMARY_LIMIT = 1500;

isolated function toGeoLocation(GeocodingMatch best) returns GeoLocation => {
    placeName: best.name,
    region: best?.admin1,
    countryName: best?.country,
    countryCode: best?.country_code,
    latitude: best.latitude,
    longitude: best.longitude,
    timeZone: best?.timezone
};

isolated function toOutlook(WeatherResponse response, string basis) returns WeatherOutlook {
    DailySeries series = response.daily;
    DailyWeather[] days = [];
    foreach int index in 0 ..< series.time.length() {
        days.push({
            date: series.time[index],
            maxTempC: valueAt(series.temperature_2m_max, index),
            minTempC: valueAt(series.temperature_2m_min, index),
            precipitationMm: valueAt(series.precipitation_sum, index)
        });
    }
    return {basis, timeZone: response?.timezone, days};
}

isolated function valueAt((decimal?)[] values, int index) returns decimal? =>
    index < values.length() ? values[index] : ();

isolated function toAdvisory(AdviceCountry country, AdviceDocument advice) returns TravelAdvisory {
    AdviceDetails details = advice.details;
    string[] alertStatus = details.alert_status ?: [];
    AdvicePart[] parts = details.parts ?: [];
    string summary = parts.length() > 0 ? toPlainText(html = parts[0].body, maxChars = SUMMARY_LIMIT) : "";
    return {
        countryName: country.name,
        adviceLevel: toAdviceLevel(alertStatus),
        alertStatus,
        latestChange: details?.change_description,
        updatedAt: advice?.public_updated_at,
        warningsSummary: summary,
        sourceUrl: string `https://www.gov.uk/foreign-travel-advice/${country.slug}`
    };
}

isolated function toAdviceLevel(string[] alertStatus) returns AdviceLevel {
    if alertStatus.indexOf("avoid_all_travel_to_whole_country") !is () {
        return "AVOID_ALL_TRAVEL";
    }
    if alertStatus.indexOf("avoid_all_but_essential_travel_to_whole_country") !is () {
        return "ESSENTIAL_TRAVEL_ONLY";
    }
    return alertStatus.length() > 0 ? "AVOID_PARTS" : "NO_FCDO_WARNING";
}

isolated function toPlainText(string html, int maxChars) returns string {
    string withoutTags = re `<[^>]*>`.replaceAll(html, " ");
    string collapsed = re `\s+`.replaceAll(withoutTags, " ").trim();
    return collapsed.length() > maxChars ? collapsed.substring(0, maxChars) + "…" : collapsed;
}
