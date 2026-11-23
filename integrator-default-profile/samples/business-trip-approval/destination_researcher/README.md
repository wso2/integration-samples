# DestinationResearcher

An agent definition that briefs a business traveler on a destination for specific dates: the place, country and time zone; the weather (a forecast when the trip is within about two weeks, otherwise the weather on the same dates in the most recent of the last three years that the historical archive covers, with 28 February standing in for 29 February); and the public holidays during the trip, when offices may be closed.

It uses the Open-Meteo geocoding, forecast and archive APIs and the Nager.Date public holidays API. None of them need an API key.

## Query

Send the destination and the trip dates, for example:

```
Kyoto, Japan, 2027-03-10 to 2027-03-13.
```

## Response

A `string` with the place, country code and time zone, a one-line weather summary, and the national and regional public holidays during the trip.

## Initialization parameters

- `model`: the model provider the agent uses.
- `memory`: optional. The memory implementation. Leave it unset for a stateless agent.

## Shared functions

`geocode`, `weatherOutlook` and `publicHolidays` are `public`, so other packages can call them directly without the agent.
