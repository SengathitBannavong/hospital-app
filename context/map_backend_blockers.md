# Map Backend Blockers

Phase J closes the client-side map work without guessing unknown backend
contracts. These items are intentionally deferred until the API contract is
confirmed.

## Meters Per Cell

Current route distances are grid-cell counts. `RouteResult.estimatedTime` is a
time quantity derived from cell count and mode speed, but the app cannot show
meters until the backend provides the meters-per-cell ratio for each map/floor.

Needed to unblock: a stable meters-per-cell field in map metadata or route
responses.

Code seam: `TODO(Phase J backend:meters-per-cell)`.

## Route ID

`route/order` does not currently provide a route id in the typed client flow.
Without that id, online `route/pass_node`, `route/recalculate`,
`route/get_steps`, and `route/get_next` cannot be safely activated. The app keeps
pass-node reporting no-op safe and uses local reroute/steps behavior.

Needed to unblock: `route/order` response returns a stable `route_id`, and the
active route model carries it through navigation.

Code seam: `TODO(Phase J backend:route-id)`.

## Cross-Floor Links

Offline routing is floor-scoped because the current map models expose
per-floor nodes/edges only. Cross-floor offline routing needs a documented
stair/elevator link model between `map_id`s and a way to slice route geometry by
floor for display.

Needed to unblock: documented cross-floor link nodes/edges, including source
floor, target floor, source cell, target cell, accessibility, and cost.

Code seam: `TODO(Phase J backend:cross-floor-links)`.

## Flow Ping

`flow/ping_location` is scaffolded but not wired from simulated navigation. The
payload and cadence need confirmation before emitting live pings.

Needed to unblock: confirmed payload fields, route id behavior, throttling
cadence, and whether pings should be queued offline.

Code seam: `TODO(Phase J backend:flow-ping)`.

## Voice Clips

On-device TTS is the active offline voice path. Server voice clips remain
optional until `sys/get_voice_files` availability and response shape are
confirmed.

Needed to unblock: confirmed voice file response shape, clip identifiers, cache
policy, and fallback behavior.

Code seam: `TODO(Phase J backend:voice-clips)`.

## Route History Fields

`route/get_history` is stubbed in `swagger.yaml`, so `RouteHistoryEntry` accepts
nullable aliases for route id, destination, mode, map id, and timestamp.

Needed to unblock: exact route history entry schema and field names.

Code seam: `TODO(Phase J backend:route-history-fields)`.

## Crowd-Aware Routing (Client Authority)

Crowd-aware routing is implemented **client-side** because the backend router is
immutable and crowd-blind. If the backend ever adds flow-weighted routing or an
`avoid_cells` param, revisit whether online should defer to it.
