import ballerina/http;
import ballerina/log;
import ballerinax/solace;

public type FlightBooked record {|
    string tripId;
    string destination;
|};

public type HotelBooked record {|
    string tripId;
    string destination;
|};

public type CarFailed record {|
    string tripId;
|};

public type HotelCancelled record {|
    string tripId;
|};

public type FlightBookedMessage record {|
    *solace:Message;
    FlightBooked payload;
|};

public type HotelBookedMessage record {|
    *solace:Message;
    HotelBooked payload;
|};

public type CarFailedMessage record {|
    *solace:Message;
    CarFailed payload;
|};

public type HotelCancelledMessage record {|
    *solace:Message;
    HotelCancelled payload;
|};

listener solace:Listener solaceListener = check new (
    url = solaceUrl,
    messageVpn = messageVpn,
    auth = {username: solaceUser, password: solacePassword}
);

service /trips on new http:Listener(8090) {
    resource function post book(FlightBooked event) returns error? {
        check flightBookedProducer->send({payload: event});
        log:printInfo("Saga initiated", tripId = event.tripId, destination = event.destination);
    }
}

@solace:ServiceConfig {queueName: "hotel-on-flight-booked"}
service solace:Service on solaceListener {
    remote function onMessage(FlightBookedMessage event) returns error? {
        FlightBooked payload = event.payload;
        log:printInfo("Room booked", tripId = payload.tripId, destination = payload.destination);
        check hotelBookedProducer->send({payload: {tripId: payload.tripId, destination: payload.destination}});
    }
}

@solace:ServiceConfig {queueName: "car-on-hotel-booked"}
service solace:Service on solaceListener {
    remote function onMessage(HotelBookedMessage event) returns error? {
        HotelBooked payload = event.payload;
        if payload.destination == "fail" {
            log:printInfo("Car booking failed, triggering compensation", tripId = payload.tripId);
            check carFailedProducer->send({payload: {tripId: payload.tripId}});
        } else {
            log:printInfo("Car reserved, saga complete", tripId = payload.tripId, destination = payload.destination);
        }
    }
}

@solace:ServiceConfig {queueName: "hotel-on-car-failed"}
service solace:Service on solaceListener {
    remote function onMessage(CarFailedMessage event) returns error? {
        log:printInfo("Compensation: room cancelled", tripId = event.payload.tripId);
        check hotelCancelledProducer->send({payload: {tripId: event.payload.tripId}});
    }
}

@solace:ServiceConfig {queueName: "flight-on-hotel-cancelled"}
service solace:Service on solaceListener {
    remote function onMessage(HotelCancelledMessage event) returns error? {
        log:printInfo("Compensation: flight released", tripId = event.payload.tripId);
    }
}
