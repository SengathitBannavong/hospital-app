# Asset / Wheelchair — backend gap & client workaround

_Verified against the live backend (`https://group3.it4788.sukkaito.id.vn/api/`)
on 2026-06-14 with a real patient account (user_id 22)._

> This is the tracked, canonical copy for contributors. The `my_booking`
> endpoint spec (human + AI-agent readable) lives next to it at
> [`doc/wheelchair_my_booking_spec.html`](wheelchair_my_booking_spec.html).

## The gap

The `/api/asset/*` surface has **7 endpoints** and **none of them returns the
caller's current booking**:

- `find_wheelchairs` lists only `available` assets — a booked one disappears.
- `asset_health` / `track_asset` return status but **no ownership field**.
- `track_asset` does **not** enforce ownership — it returns `1000` for *any*
  asset (confirmed: WL-002/003/005/010 all succeed while not booked). The
  client's `accessDenied` (1009) handling for track is therefore effectively
  dead code against the current backend.
- `book_asset` rejects a second booking with **code `1010`** and a useless
  `message: "OK"` — it does **not** say which asset the user already holds.

Net effect: the server tracks a booking but the client has **no reliable way to
ask "what wheelchair am I holding?"**. A booking made on another phone or before
a reinstall is invisible to the app, yet `book_asset` keeps returning `1010`.

## How the app knows ownership today (and its limits)

- **Booked on this device →** certain: `book_asset` success saves the exact
  `asset_id` to local Hive (`active_asset`). The "mine" flag drives release/track.
- **Recovered (reinstall / another phone) →** a **guess**: there is no owner
  field and `track_asset` isn't ownership-gated, so the client cannot tell its
  in-use chair from another user's (see workaround below).
- **Safety net:** the BE `ReleaseAsset` re-checks ownership
  (`FindActiveBookingByUser(userID)` then `booking.Device.DeviceCode != assetID
  → ErrDeviceOwnership`), so a wrong guess can only mislead the *display* — it
  can never release/modify someone else's chair.

## What the backend should add (request to BE team)

Either of:
1. `GET /api/asset/my_booking` → `{ booking_id, asset_id, status, station_id }`
   for the authenticated user (preferred — full spec in
   `doc/wheelchair_my_booking_spec.html`), **or**
2. include the held `asset_id` in the `1010` error `data`, **and** make
   `track_asset` enforce ownership (return `1009` for assets not booked by the
   caller) so the client can verify.

## `release_asset` station mismatch — ROOT CAUSE + FE workaround shipped

Verified live (WL-001, the test account's held chair):

- `station_id` must be a **string** — sending an int returns `2005 "Request
  body invalid"`.
- With a valid string station id (tried "1".."4", all real per
  `asset_stations`), release returned **`4004` (mapResourceNotFound)** with
  `message:"OK"` and never succeeded.

`release_asset` resolves the station by **`station_name`**, not the numeric PK:
`FindStationByCode` runs `WHERE station_name = ? AND is_active = true`
(`repository/device_repo.go:43`). The app was sending the numeric `station_id`
PK from `/asset/asset_stations` (per swagger `station_id: "1"`), which never
matches a name → `ErrStationNotFound` → `4004`. The `"OK"` message is because
`handleDeviceError` returns `SuccessWithCode(c, 4004, nil)` and `SuccessWithCode`
hardcodes `Message: "OK"` (`pkg/response.go:280`) — this is why *all* device
errors (incl. book's `1010`) carry `message:"OK"`. `current_node_id` is **not**
involved in release.

**FE workaround (shipped):** the release station picker now sends
`AssetStation.stationName` as `station_id`. Verified live: release with
`"Trạm Sảnh Chính - Tầng 1"` → `1000`, asset flips to `available`, re-book
succeeds. Full book→release→book loop works.

> ⚠️ **Coupling:** the FE now depends on the BE matching by `station_name`. If
> the BE switches to PK-only, the FE must switch back to sending the PK the same
> day. Ideally the BE accepts **both**.

## `asset_stations` has no location → release-by-position blocked

`asset_stations` returns only `station_id, station_name, capacity,
available_wheelchairs` — **no `poi_id` and no coordinates**. The user's position
is a map grid cell. With no station location the client cannot compute the
nearest station, so "release at my current position / nearest station" is not
possible. **BE ask:** add `poi_id` (or grid/coords) to each station row; then the
release picker can default to the nearest station to the user.

## Summary of backend fixes owed

1. `release_asset`: accept the numeric `station_id` PK (keep `station_name`
   fallback) so the FE can stop sending the renameable name.
2. Stop using `SuccessWithCode` for errors so `message` is descriptive instead
   of `"OK"` (affects book's `1010`, release's `4004`).
3. Add `GET /api/asset/my_booking` (`device_bookings` + `FindActiveBookingByUser`
   already exist) so the client can drop the in-use discovery heuristic and
   ownership becomes exact + cross-device.
4. Add `poi_id`/coords to `asset_stations` for release-by-nearest-station.
5. (Optional) make `track_asset` ownership-gated (1009 when not the caller's).

## Client workaround (shipped)

Because the backend can't answer "which asset is mine", the app:

- Persists the booking locally (Hive box `active_asset`) on `book_asset`
  success, clears it on `release_asset` success.
- **Recovers** a lost/cross-device booking heuristically
  (`AssetRepository.discoverInUseAssets`): call `find_wheelchairs` with a huge
  radius to get the *available* set, infer the catalog as
  `WL-001..WL-{maxDeviceId}`, and the **gaps** (ids not available) confirmed
  `in_use` via `asset_health` are the booked ones.
  - Exactly one in-use → adopted automatically as the user's booking.
  - Several in-use → the user picks which is theirs ("Xe lăn của tôi" page).
- Triggers recovery automatically when `book_asset` throws
  `AlreadyBookingException` (code 1010) with no local booking.

### Fragility of the workaround

- Assumes asset ids are `WL-` + zero-padded 3-digit `device_id`, contiguous
  from 1. If the catalog format/range changes, discovery misses assets.
- With multiple concurrent users, several assets are `in_use` and the app cannot
  prove which is the caller's — it can only present candidates to confirm.

All of this becomes unnecessary once the backend exposes `my_booking` (fix #3).
