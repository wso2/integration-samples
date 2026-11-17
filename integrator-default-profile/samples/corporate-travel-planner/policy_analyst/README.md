# PolicyAnalyst

An agent definition that checks candidate flights and hotel rates against the company travel policy and recommends the cheapest combination that complies. The checks themselves are ordinary code (`evaluateTrip`): the agent explains the result but never decides it.

The policy covers the allowed cabin (with an upgrade for long-haul legs), a nightly hotel cap, a trip cap, advance booking, refundability, and the UK FCDO travel advice for the destination. Amounts are converted to USD at the latest European Central Bank reference rate (Frankfurter API, no key needed). The policy table in `functions.bal` stands in for a real travel-policy service.

## Query

Send the destination country and the candidate IDs from the LogisticsCoordinator agent, for example:

```
Destination: Japan. Flights: off_0000A1, off_0000A2. Hotel rates: rat_0000B1, rat_0000B2.
```

## Context

Set `travelerGrade` (for example `staff` or `director`) on the `ai:Context` passed to `run`. The agent reads the grade from there, never from the query, so a user cannot talk it into a more generous policy.

## Response

A `string` recommending a combination, with its USD total and any violations and warnings.

## Initialization parameters

- `model`: the model provider the agent uses.
- `memory`: optional. The memory implementation. Leave it unset for a stateless agent.

## Shared functions

`evaluateTrip`, `getPolicy`, `adviceLevelFor` and `convertCurrency` are `public`.
