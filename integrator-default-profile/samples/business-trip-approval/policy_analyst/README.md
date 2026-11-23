# PolicyAnalyst

An agent definition that checks a business trip against the company travel policy: whether it can be submitted, whether it needs a second approval from the manager's manager, and what the traveler and approvers should know. The checks themselves are ordinary code (`evaluateTrip`): the agent explains the result but never decides it.

| Rule | Result |
| --- | --- |
| The FCDO advises against all travel to the country | Blocked |
| The FCDO advises against all but essential travel | Needs a second approval, and a justification (blocked without one) |
| The FCDO advises against travel to parts of the country | Warning |
| The trip is longer than the grade allows without escalation (staff 10 days, director 21, VP 30) | Needs a second approval |
| The trip is longer than 90 days, starts in the past, or ends before it starts | Blocked |
| Less notice than the grade asks for (staff 14 days, director 7, VP 3) | Warning |
| A public holiday at the destination falls during the trip | Warning |
| The FCDO advice or the public holidays could not be checked | Warning |

`checkTrip` looks up the FCDO advice (through the TravelAdvisor package) and the public holidays (through the DestinationResearcher package), then calls `evaluateTrip`. The policy table in `functions.bal` stands in for a real travel-policy service.

## Query

Send the destination country, its two-letter code, the dates, and any justification, for example:

```
Japan (JP), 2027-03-10 to 2027-03-13.
```

## Context

Set `travelerGrade` (for example `staff` or `director`) on the `ai:Context` passed to `run`. The agent reads the grade from there, never from the query, so a user cannot talk it into a more generous policy.

## Response

A `string` with whether the trip can be submitted, and every blocker, second-approval reason and warning.

## Initialization parameters

- `model`: the model provider the agent uses.
- `memory`: optional. The memory implementation. Leave it unset for a stateless agent.

## Shared functions

`checkTrip`, `evaluateTrip` and `getPolicy` are `public`.
