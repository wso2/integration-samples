# A place resolved by the geocoder.
public type GeoLocation record {|
    # The place's name, as the geocoder spells it
    string placeName;
    # The state, province or other first-level region, when known
    string? region;
    # The country's English name, when known
    string? countryName;
    # The two-letter ISO 3166-1 country code, when known
    string? countryCode;
    # Latitude in degrees
    decimal latitude;
    # Longitude in degrees
    decimal longitude;
    # The IANA time zone, e.g. "Asia/Tokyo", when known
    string? timeZone;
|};

# The weather for one day.
public type DailyWeather record {|
    # The day (YYYY-MM-DD)
    string date;
    # The highest temperature in °C, when known
    decimal? maxTempC;
    # The lowest temperature in °C, when known
    decimal? minTempC;
    # Total precipitation in mm, when known
    decimal? precipitationMm;
|};

# The weather for the days of a trip: a forecast, or the same dates in an earlier year.
public type WeatherOutlook record {|
    # "forecast" for trips within the forecast window, otherwise the year whose same dates are used
    string basis;
    # The destination's IANA time zone, when known
    string? timeZone;
    # One entry per day of the trip
    DailyWeather[] days;
|};

# A public holiday at the destination.
public type PublicHoliday record {|
    # The day of the holiday (YYYY-MM-DD)
    string date;
    # The holiday's English name
    string name;
    # The holiday's name in the local language
    string localName;
    # True when the holiday applies to only some regions of the country
    boolean regional;
    # ISO 3166-2 codes of the regions it applies to, when regional
    string[] regions;
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

// ---- Nager.Date wire types ----

type NagerHoliday record {
    string date;
    string localName;
    string name;
    string countryCode;
    boolean global;
    string[]? counties;
};
