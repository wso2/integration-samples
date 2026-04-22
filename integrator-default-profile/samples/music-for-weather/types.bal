
type Location record {|
    string name;
    string region;
    string country;
    decimal lat;
    decimal lon;
    string tz_id;
    int localtime_epoch;
    string localtime;
|};

type Condition record {|
    string text;
    string icon;
    int code;
|};

type Current record {|
    int last_updated_epoch;
    string last_updated;
    decimal temp_c;
    decimal temp_f;
    int is_day;
    Condition condition;
    decimal wind_mph;
    decimal wind_kph;
    int wind_degree;
    string wind_dir;
    int pressure_mb;
    decimal pressure_in;
    decimal precip_mm;
    decimal precip_in;
    int humidity;
    int cloud;
    decimal feelslike_c;
    decimal feelslike_f;
    decimal windchill_c;
    decimal windchill_f;
    decimal heatindex_c;
    decimal heatindex_f;
    decimal dewpoint_c;
    decimal dewpoint_f;
    int vis_km;
    int vis_miles;
    decimal uv;
    decimal gust_mph;
    decimal gust_kph;
|};

type WeatherData record {|
    Location location;
    Current current;
|};

type External_urls record {|
    string spotify;
|};

type ImagesItem record {|
    string url;
    int|json|() height;
    int|json|() width;
|};

type Owner record {|
    External_urls external_urls;
    string href;
    string id;
    string 'type;
    string uri;
    string display_name;
|};

type Tracks record {|
    string href;
    int total;
|};

type ItemsItem record {|
    boolean collaborative;
    string description;
    External_urls external_urls;
    string href;
    string id;
    ImagesItem[] images;
    string name;
    Owner owner;
    boolean 'public;
    string snapshot_id;
    Tracks tracks;
    string 'type;
    string uri;
    json primary_color;
|};

type Playlists record {
    string href;
    int 'limit;
    string next;
    int offset;
    json? previous;
    int total;
    ItemsItem?[] items;
};

type SpotifyPlayList record {|
    Playlists playlists;
|};

type PlaylistInfo record {|
    string name;
    string url;
    string artist;
|};

type MusicSuggestion record {|
    string location;
    string weather;
    string musicMood;
    PlaylistInfo[] playlist;
|};
