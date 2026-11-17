# A place resolved by the geocoder.
public type GeoLocation record {|
    string placeName;
    string? region;
    string? countryName;
    string? countryCode;
    decimal latitude;
    decimal longitude;
    string? timeZone;
|};

public type DailyWeather record {|
    string date;
    decimal? maxTempC;
    decimal? minTempC;
    decimal? precipitationMm;
|};

public type WeatherOutlook record {|
    # "forecast" for trips within the forecast window, otherwise "same dates last year"
    string basis;
    string? timeZone;
    DailyWeather[] days;
|};

# UK FCDO advice level for a country.
public type AdviceLevel "AVOID_ALL_TRAVEL"|"ESSENTIAL_TRAVEL_ONLY"|"AVOID_PARTS"|"NO_FCDO_WARNING";

public type TravelAdvisory record {|
    string countryName;
    AdviceLevel adviceLevel;
    string[] alertStatus;
    string? latestChange;
    string? updatedAt;
    string warningsSummary;
    string sourceUrl;
|};

// ---- Open-Meteo wire types ----

type GeocodingMatch record {
    string name;
    decimal latitude;
    decimal longitude;
    string? country?;
    string? country_code?;
    string? admin1?;
    string? timezone?;
};

type GeocodingResponse record {
    GeocodingMatch[] results?;
};

type DailySeries record {
    string[] time;
    (decimal?)[] temperature_2m_max;
    (decimal?)[] temperature_2m_min;
    (decimal?)[] precipitation_sum;
};

type WeatherResponse record {
    string? timezone?;
    DailySeries daily;
};

// ---- GOV.UK Content API wire types ----

type AdviceCountry record {
    string name;
    string slug;
    string[] synonyms?;
};

type AdviceIndexDetails record {
    AdviceCountry country?;
};

type AdviceIndexChild record {
    string title;
    AdviceIndexDetails details?;
};

type AdviceIndexLinks record {
    AdviceIndexChild[] children;
};

type AdviceIndex record {
    AdviceIndexLinks links;
};

type AdvicePart record {
    string title;
    string body;
};

type AdviceDetails record {
    string[] alert_status?;
    string? change_description?;
    AdvicePart[] parts?;
};

type AdviceDocument record {
    string title;
    string? public_updated_at?;
    AdviceDetails details;
};
