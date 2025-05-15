function storeAddress(string address, GeoCodeResponse geocode) returns error? {
    json jsonResult = check firebaseClient->/location/[address]/location\.json.put(geocode, targetType = json);
}
