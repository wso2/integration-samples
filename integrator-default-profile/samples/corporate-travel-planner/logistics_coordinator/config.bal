# Duffel API base URL.
configurable string duffelBaseUrl = "https://api.duffel.com";
# Duffel access token. A `duffel_test_...` token uses Duffel's test mode.
configurable string duffelAccessToken = ?;
# Duffel test mode only stocks test hotels at a fixed location. When true, hotel searches use that location
# instead of the destination's coordinates. Set to false with a live token.
configurable boolean useDuffelTestHotels = true;
