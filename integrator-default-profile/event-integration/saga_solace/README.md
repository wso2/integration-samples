# Saga (Choreography) with Solace PubSub+

Demonstrates a choreography-based Saga: a trip booking coordinates flight → hotel in sequence. If a downstream step fails, compensation events unwind the completed steps. All three services share one named Solace listener; each binds to its queue via `@solace:ServiceConfig`.

## How it works

**Happy path:** `POST /trips/book` → FlightBooked → hotel books room → HotelBooked

**Compensation:** `POST /trips/book` with `destination=fail` → CarFailed → hotel cancels room → HotelCancelled → flight releases seat

## Prerequisites

- Solace PubSub+ broker (default: `smf://localhost:55554`, VPN `default`, user `admin`/`admin`)
- Queues subscribed to their topics (run once after starting Solace):

```bash
solace-cli queue create hotel-on-flight-booked    --subscription trip/flight/booked
solace-cli queue create car-on-hotel-booked       --subscription trip/hotel/booked
solace-cli queue create hotel-on-car-failed       --subscription trip/car/failed
solace-cli queue create flight-on-hotel-cancelled --subscription trip/hotel/cancelled
```

## Run locally

```bash
bal run
# Trigger happy path
curl -X POST http://localhost:8090/trips/book \
  -H 'Content-Type: application/json' \
  -d '{"tripId":"t1","destination":"Paris"}'
# Trigger compensation path
curl -X POST http://localhost:8090/trips/book \
  -H 'Content-Type: application/json' \
  -d '{"tripId":"t1","destination":"fail"}'
```

## Deploy on Devant

Deploy this integration on **Devant** as an **Event Integration**.

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant-White.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/integrator-default-profile/event-integration/saga_solace)
