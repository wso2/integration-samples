import ballerina/http;

final http:Client geoCodingClient = check new ("http://api.maps.googleapis.com.balmock.io");
final http:Client firebaseClient = check new ("http://api.mapsproject.firebase.com.balmock.io");
