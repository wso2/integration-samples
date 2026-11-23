# TravelAdvisor

An agent definition that briefs a business traveler on the UK Foreign, Commonwealth & Development Office (FCDO) travel advice for a country: the advice level and current warnings, the entry requirements, and the safety and health advice that matter for a short business trip. The FCDO writes its entry requirements for British passport holders, and the agent says so.

It uses the GOV.UK Content API, which needs no API key.

## Query

Send the destination country, and anything specific to find out, for example:

```
Japan. The traveler is visiting a customer for four days.
```

## Response

A `string` with the advice level and warnings, the entry requirements, the key safety and health points, and the GOV.UK page.

## Initialization parameters

- `model`: the model provider the agent uses.
- `memory`: optional. The memory implementation. Leave it unset for a stateless agent.

## Shared functions

`travelAdvisory` and `adviceSection` are `public`, so other packages can call them directly without the agent. `travelAdvisory` returns the advice level: `AVOID_ALL_TRAVEL` and `ESSENTIAL_TRAVEL_ONLY` apply to the whole country, and `AVOID_PARTS` means the FCDO advises against travel to some areas.
