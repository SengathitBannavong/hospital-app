# API Contract Overview — Frontend ↔ Backend

_Full two-sided reconciliation, refreshed 2026-05-31. Backend side from codex
audit on the backend repo plus current frontend usage._

Backend wraps **all** successful responses as `{ code, message, data }`
(`pkg/response.go:162`); tables describe the shape of `data`. The app reads that
nested `data` via its `ApiResponse`/`AuthApiResponse`/`MedicalApiResponse`
wrappers.

**Verdicts:** MATCH · MISMATCH · MISSING (no backend route) · VERIFY (shapes
likely differ / not fully confirmed) · n/a (app doesn't call it).

---

## Table 1 — Responses (what the backend returns)

### Auth
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| auth/login | `data` parsed as **AuthUser** (flat: user_id, full_name, phone_number, token, …) | flat `{user_id, full_name, phone_number, token, accessToken, refreshToken, avatar, active, role}` | **MATCH** (app reads flat — earlier "nested user" was wrong) |
| auth/signup | `OtpResponse {otp_code?}` | `{user_id, otp_code?}` | MATCH |
| auth/verify_otp | ignored (void) | `null` | MATCH |
| auth/resend_otp | `OtpResponse` | route **MISSING** | **MISSING** |
| auth/forgot_password | `OtpResponse {otp_code?}` | `{otp_code?}` | MATCH |
| auth/reset_password | ignored (void) | `null` | MATCH |
| auth/logout | n/a — app logs out locally, never calls backend | `null` | n/a |
| auth/change_password | ignored (void) | `null` | MATCH |
| user/delete_account | ignored (void) | `{id}` | MATCH |

### System / Utility
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| util/check_version | `UtilVersionCheck {status, latest_version, download_url, change_log}` | util version payload | MATCH |
| sys/check_version | legacy path no longer used by app startup | same | n/a |
| sys/get_voice_key | reads `api_key` (returns String?) | `{provider, api_key, language, enabled}` | MATCH |
| sys/get_voice_files | builds `Map<String,String>` from `files` | `{language, base_url, files:[{key,url,text}]}` | MATCH |

### Profile
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| user/get_profile | `UserProfile {user_id, full_name, phone_number, dob?, gender?, avatar?}` | same | MATCH |
| user/set_profile | `UserProfile` | same | MATCH |

### Settings
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| user/set_devtoken | ignored (void) | `null` | MATCH |
| user/get_settings | `{notification(bool), language, theme}` | `{language, theme, notification}` | MATCH |
| user/set_settings | ignored (void) | `null` | MATCH |

### Medical
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| medical/get_tasks | `MedicalTask[]` | `Treatment[]` (`schema/medical.go:41`) | MATCH |
| medical/get_queue | `QueueStatus` (query poi_id) | `Queue {queue_id, poi_id, current_number, waiting_count, avg_wait_minutes, updated_at}` | MATCH |
| medical/checkin_room | bool (success) | `{checkin:true}` | MATCH |
| medical/checkout_room | bool | `{checkout:true}` | MATCH |
| medical/result_status | `ResultStatus` | `{treatment_id, task_name, status, has_result}` | MATCH |
| medical/get_prescription | `Prescription[]` (uses first) | `Prescription[]` | MATCH |
| medical/sync_now | bool | `{synced:true}` | MATCH |
| medical/room_open | `RoomOpen` | `{poi_id, poi_name, open, close}` | MATCH |
| medical/cancel_task | bool | not in backend doc | **VERIFY** route exists |
| medical/get_history | `MedicalTask[]` | not in backend doc | **VERIFY** route exists |

### Map
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| map/get_floors | `MapFloor[]` | `MapItem[]` | MATCH |
| map/get_nodes | `MapPoi[]` | `POIItem[]` | MATCH |
| map/get_edges | `MapEdgesResponse {map_id, total, edges[]}` | same | MATCH |
| map/get_meta | `MapFloor {…, grid_data}` | `{map_id, map_name, rows, cols, grid_data, map_image_url}` | MATCH |
| map/get_depts | `MapDepartment[]` | `POIItem[]` or ward counts | **VERIFY** (shape may differ) |
| map/search_location | `MapPoi[]` | `POIItem[]` | MATCH |
| map/get_landmarks | `MapPoi[]` | `POIItem[]` | MATCH |
| map/sync_full | `MapSyncFull {maps, pois}` | `{maps, pois}` | MATCH |

### Route
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| route/get_modes | `RouteMode[] {mode_id, mode_name, speed_factor}` | `TravelMode[]` same | MATCH |
| route/preview | `{distance, estimated_time, steps[], mode_id, speed_factor}` | same | MATCH |
| route/order | route + paths | `{route, paths}` | MATCH |
| route/order_multi | route + paths | `{route, paths}` | MATCH |
| route/order_unordered | route + paths | `{route, paths}` | MATCH |
| route/get_steps | — | `RoutePath[]` | n/a (app doesn't call) |
| route/get_next | — | `RoutePath[]` | n/a |
| route/recalculate | route + paths | `{route, paths}` | MATCH |
| route/pass_node | — | `{recorded:true}` | n/a (stub, not wired) |
| route/get_history | `RouteHistory {routes, total, page, limit}` | same | MATCH |
| route/clear_history | `RouteClearHistory {cleared:true}` | `{cleared:true}` | MATCH |

### Flow
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| flow/get_density | `FlowCell[]` | `{grid_location, count, window_minutes}` (single) | **VERIFY** (list vs single) |
| flow/get_heatmap | `FlowCell[]` | `[{grid_location, density}]` | MATCH |
| flow/get_bottlenecks | `FlowCell[]` | `[{grid_location, count}]` | MATCH |
| flow/get_forecast | `FlowForecastBucket[]` | `[{hour, count}]` | MATCH |
| flow/get_alerts | `FlowAlert[]` | `PriorityRoute[]` | MATCH (verify field map) |
| flow/edge_status | `EdgeStatus[]` (list) | single `{edge_id, current_count, fill_percentage}` | **MISMATCH** (list vs single) |
| flow/report_obstacle | `ObstacleReport` | same | MATCH |
| flow/get_obstacles | `MapObstacle[]` (list) | `{reports, total, page, limit}` | **VERIFY** (app must read `.reports`) |

### Notification
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| notification/get_list | `{notifications:[{notif_id, title, content, is_read, created_at}], total, page, limit}` | same | MATCH |
| notification/set_read | ignored | `{updated:true}` | MATCH |
| notification/delete | ignored | `{deleted:true}` | MATCH |

### Chat
| Endpoint | Frontend expects | Backend returns | Verdict |
| --- | --- | --- | --- |
| chat/get_rooms | list or `{rooms/data:[...]}` with room id, name, last message, unread count | room list payload | **VERIFY** (defensive parser accepts both) |
| chat/get_messages | list or `{messages/data:[...], total, page, limit}` | paginated message payload | **VERIFY** (defensive parser accepts both) |
| chat/participants | `{patients:[...], staffs:[...]}` | participant lists | MATCH |
| chat/send_message | `ChatMessage` | message payload | MATCH |
| chat/mark_read | ignored | success wrapper | MATCH |
| chat/close_room | ignored | success wrapper | MATCH |
| ws/chat | per-room broadcast message payload | message fields without room id | MATCH (room id implicit in socket URL) |

---

## Table 2 — Requests (what the backend expects)

### Auth
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| auth/login | `{phone_number, password}` | `phone_number`/`phone`, `password` (+ optional device_token, platform) | MATCH |
| auth/signup | `{full_name, phone_number, password, dob?, gender?}` | same required + optional dob/gender | MATCH |
| auth/verify_otp | `{phone_number, otp_code, otp_type}` | `phone_number`/`phone`, `otp`/`otp_code`, optional `otp_type` | MATCH |
| auth/resend_otp | (app method exists; signup-resend disabled) | route **MISSING** | **MISSING** |
| auth/forgot_password | `{phone_number}` | `phone_number`/`phone` | MATCH |
| auth/reset_password | `{phone_number, otp_code, new_password}` | `phone_number`/`phone`, `otp`/`otp_code`, `new_password` | MATCH |
| auth/logout | n/a (not called) | optional body `{fcm_token}` | n/a |
| auth/change_password | `{old_password, new_password}` | same | MATCH |
| user/delete_account | `{password}` | `{password}` | MATCH |

### System / Utility
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| util/check_version | query `{platform, code}` | query `platform`, `code` | MATCH |
| sys/check_version | n/a | query `platform` (android/ios), `app_version` | n/a |
| sys/get_voice_key | no params | none | MATCH |
| sys/get_voice_files | no params | none | MATCH |

### Profile
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| user/get_profile | no body | auth, none | MATCH |
| user/set_profile | partial `{full_name?, dob?, gender?, avatar?}` | partial same | MATCH |

### Settings
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| user/set_devtoken | `{device_token, platform}` | same (android/ios) | MATCH |
| user/get_settings | no body | auth, none | MATCH |
| user/set_settings | `{notification, language, theme}` (partial ok) | partial `{language?, theme?, notification?}` | MATCH |

### Medical
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| medical/get_tasks | no params | auth, none | MATCH |
| medical/get_queue | query `{poi_id}` | query `poi_id` | MATCH |
| medical/checkin_room | `{treatment_id}` | `{treatment_id}` | MATCH |
| medical/checkout_room | `{treatment_id}` | `{treatment_id}` | MATCH |
| medical/result_status | query `{treatment_id}` | query `treatment_id` | MATCH |
| medical/get_prescription | no params | auth, none | MATCH |
| medical/sync_now | no body | auth, none | MATCH |
| medical/room_open | query `{poi_id}` | query `poi_id` | MATCH |
| medical/cancel_task | `{treatment_id}` | not in backend doc | **VERIFY** |
| medical/get_history | no params | not in backend doc | **VERIFY** |

### Map
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| map/get_floors | no params | none | MATCH |
| map/get_nodes | query `{map_id}` | `map_id`/`floor_id` | MATCH |
| map/get_edges | query `{map_id}` | `map_id`/`floor_id` | MATCH |
| map/get_meta | query `{map_id}` | `map_id`/`floor_id` | MATCH |
| map/get_depts | no params | optional `node_type`, `ward_id` | MATCH |
| map/search_location | query `{keyword, map_id}` | `keyword`, optional `map_id`/`floor_id` | MATCH |
| map/get_landmarks | query `{map_id}` | optional `map_id`/`floor_id` | MATCH |
| map/sync_full | query `{map_id}` | optional `map_id`/`floor_id` | MATCH |

### Route
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| route/get_modes | no params | none | MATCH |
| route/preview | `{start_location, dest_location, mode_id}` | same (aliases also accepted) | MATCH |
| route/order | `{start_location, dest_location, mode_id}` | same | MATCH |
| route/order_multi | `{start_location, target_locations[], mode_id}` | same | MATCH |
| route/order_unordered | `{start_location, target_locations[], mode_id}` | same | MATCH |
| route/get_steps | n/a | query `route_id` | n/a |
| route/get_next | n/a | query `route_id` | n/a |
| route/recalculate | `{route_id, current_location}` | same (alias current_node) | MATCH |
| route/pass_node | n/a | `{route_id, grid_location}` | n/a (stub) |
| route/get_history | query `{limit, page}` | optional `page`, `limit` | MATCH |
| route/clear_history | no body | auth, none | MATCH |

### Flow
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| flow/get_density | query `{grid_location?}` (optional) | requires one of `grid_location`/`route_id` | **VERIFY** (app may omit required param) |
| flow/get_heatmap | no params | optional `route_id` | MATCH |
| flow/get_bottlenecks | query `{limit}` | optional `limit` | MATCH |
| flow/get_forecast | query `{hours}` | optional `hours`/`time_offset` | MATCH |
| flow/get_alerts | no params | none | MATCH |
| flow/edge_status | **no params** | requires `grid_location`/`edge_id` | **MISMATCH** (app sends no required param) |
| flow/ping_location | `{grid_location, grid_row, grid_col, route_id?}` | `{grid_location, grid_row, grid_col}` + optional route_id | MATCH |
| flow/report_obstacle | `{grid_location, report_type, description?, route_id?}` | `{grid_location, report_type}` + optional | MATCH |
| flow/get_obstacles | query `{status?}` | optional `status, page, limit` | MATCH (request) |

### Notification
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| notification/get_list | query `?page=&limit=` | optional `page`, `limit` | MATCH |
| notification/set_read | `{notif_id:<int>}` | `{notif_id}` | MATCH |
| notification/delete | `{notif_id:<int>}` single | `{notif_id}` single | MATCH |

### Chat
| Endpoint | Frontend sends | Backend wants | Verdict |
| --- | --- | --- | --- |
| chat/get_rooms | query `{page, limit}` | optional pagination | MATCH |
| chat/get_messages | query `{conversation_id, page, limit}` | same | MATCH |
| chat/participants | no params | none | MATCH |
| chat/send_message | `{conversation_id, type, text_content?, media_url?}` | same | MATCH |
| chat/mark_read | `{conversation_id}` | same | MATCH |
| chat/close_room | `{conversation_id}` | same | MATCH |
| ws/chat | URL query `{conversation_id, token}` | same | MATCH |

---

## Mismatches & things to fix (priority order)

1. **`flow/edge_status`** 🔴 — app calls it with **no query**, but backend requires
   `grid_location` or `edge_id`, and returns a **single** object while the app
   expects a **list** (`EdgeStatus[]`). Will fail / parse wrong. Fix app to pass a
   param + read single, or change backend to return all edges.
2. **`auth/resend_otp`** 🟠 — backend route MISSING (service exists, unrouted). App
   has the method; signup OTP resend can't work until the route is registered.
3. **`flow/get_density`** 🟠 — app omits the required `grid_location`/`route_id`,
   and backend returns a single object vs the app's `FlowCell[]`. Verify usage.
4. **`flow/get_obstacles`** 🟡 — backend returns `{reports, total, page, limit}`;
   app expects a list — confirm it reads `.reports`.
5. **`map/get_depts`** 🟡 — app expects `MapDepartment[]`; backend returns
   `POIItem[]` or ward counts. Confirm shapes line up.
6. **`medical/cancel_task`, `medical/get_history`** 🟡 — the app calls these but they
   weren't in the backend audit. Confirm the routes exist.
7. **Chat response shapes** 🟡 — current parser accepts list and nested
   `{rooms/messages/data}` shapes. Confirm exact backend payloads before
   tightening models.

### Resolved / confirmed good
- `auth/login` is a **MATCH** — the app parses `data` as a flat `AuthUser`
  (correcting the earlier "expects nested user" assumption).
- All of Notification, Settings, Profile, Utility version-check, and the core
  Medical/Map/Route request+response contracts line up.
- Response wrapping `{code,message,data}` is handled everywhere by the app's
  wrappers.
