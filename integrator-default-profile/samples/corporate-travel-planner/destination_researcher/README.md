# DestinationResearcher

An agent definition that briefs a business traveler on a destination for specific dates: the time zone, the weather (a forecast when the trip is within about two weeks, otherwise last year's weather on the same dates), and the UK FCDO travel advice level with current warnings.

It uses the Open-Meteo geocoding, forecast and archive APIs and the GOV.UK Content API. None of them need an API key.

## Query

Send the destination and the trip dates, for example:

```
Kyoto, Japan, 2027-03-10 to 2027-03-13.
```

## Response

A `string` with the time zone, a one-line weather summary, the FCDO advice level and any warnings that matter for the trip.

## Initialization parameters

- `model`: the model provider the agent uses.
- `memory`: optional. The memory implementation. Leave it unset for a stateless agent.

## Shared functions

`geocode`, `weatherOutlook` and `travelAdvisory` are `public`, so other packages can call them directly without the agent.
