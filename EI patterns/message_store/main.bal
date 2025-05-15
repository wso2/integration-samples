import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api on httpListener {
    resource function get location(string address) returns GeoCodeResponse|error {
        GeoCodeResponse|error storedGeocode = firebaseClient->/location/[address]/location\.json();
        if storedGeocode !is error {
            return storedGeocode;
        }
        GeoCodeResponse geocode = check geoCodingClient->/maps/api/geocode/'json.get(place = address);
        future<error?> futureResult = start storeAddress(address, geocode);
        return geocode;
    }
}
