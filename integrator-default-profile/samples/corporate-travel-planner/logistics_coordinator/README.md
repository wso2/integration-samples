# LogisticsCoordinator

An agent definition that finds flights and a hotel for a business trip through the [Duffel](https://duffel.com) Flights and Stays APIs. Every option it returns carries an exact `offerId` or `rateId`, so another package can propose and later book it.

## Query

Send the origin, destination, dates, cabin and, if known, the meeting location, for example:

```
Round trip LHR to Tokyo, out 2027-03-10, back 2027-03-14, economy. Hotel near Marunouchi, 2027-03-10 to 2027-03-14.
```

## Response

A `string` listing the best flight offers and hotel rates with their IDs, prices, currencies and refundability.

## Initialization parameters

- `model`: the model provider the agent uses.
- `memory`: optional. The memory implementation. Leave it unset for a stateless agent.

## Configuration

Set these in the `Config.toml` of the package that runs the agent, under `[wso2.logistics_coordinator]`:

- `duffelAccessToken` (required): a Duffel access token. A `duffel_test_...` token uses Duffel's test mode.
- `duffelBaseUrl` (optional): defaults to `https://api.duffel.com`.
- `useDuffelTestHotels` (optional): defaults to `true`. Duffel test mode only stocks test hotels at one location, so hotel searches go there. Set it to `false` with a live token.

## Shared functions

Booking is deliberately not an agent tool. The package that runs the agent books an approved option with `currentFare`, `createFlightOrder`, `createHotelQuote` and `createHotelBooking`, and validates IDs with `findFlightOffer` and `findHotelRate`. Orders, quotes and bookings are never retried automatically, so a network retry cannot book twice. When an order or booking call fails, `isOutcomeUnknown` says whether Duffel may have booked it anyway (no response, a server error, or an unreadable success response), so the caller can ask for a check instead of reporting a failure.

Flight searches leave out offers that need passport details, which this sample does not collect, and hotel rates leave out rates that cannot be paid from the Duffel balance. Each hotel rate carries `dueAtAccommodationAmount`, the mandatory fees paid at the hotel on top of the booking total, or nil when Duffel does not know them. Each offer reports its highest cabin across all segments, and `longestLegHours` is the longest single flight, without connection time. `cabinRank` orders cabins for policy checks.
