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
    # "forecast" for trips within the forecast window, otherwise the year whose same dates are used
    string basis;
    string? timeZone;
    DailyWeather[] days;
|};

# A public holiday at the destination.
public type PublicHoliday record {|
    string date;
    # The holiday's English name
    string name;
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
