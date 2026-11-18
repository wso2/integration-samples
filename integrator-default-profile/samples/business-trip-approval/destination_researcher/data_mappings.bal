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

isolated function toHoliday(NagerHoliday holiday) returns PublicHoliday => {
    date: holiday.date,
    name: holiday.name,
    localName: holiday.localName,
    regional: !holiday.global,
    regions: holiday.counties ?: []
};
