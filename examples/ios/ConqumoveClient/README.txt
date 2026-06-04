CONQUMOVE CLIENT EXAMPLE

This folder contains a source-first Swift client skeleton aligned with the current backend contract.

Files:
- Sources/ConqumoveClient/Models.swift
  Codable models for auth, nearby subscription contract, and cable payloads.
- Sources/ConqumoveClient/AuthSessionStore.swift
  Actor-based session persistence backed by UserDefaults.
- Sources/ConqumoveClient/ConqumoveAPIClient.swift
  Register, login, me, refresh, logout, and nearby subscription contract loading.
  Authenticated requests retry once after a 401 by rotating through /api/v1/auth/refresh.
- Sources/ConqumoveClient/CableSubscriptionClient.swift
  Connects to Action Cable through query-token auth and subscribes to nearby hex channels.
- Sources/ConqumoveClient/ExampleUsage.swift
  Minimal login + nearby contract fetch + websocket subscribe flow.

Backend contract assumptions:
- Register: POST /api/v1/auth/register
- Login: POST /api/v1/auth/login
- Refresh: POST /api/v1/auth/refresh
- Logout: DELETE /api/v1/auth/logout
- Me: GET /api/v1/auth/me
- Nearby realtime contract: GET /api/v1/realtime/subscriptions/nearby
- Cable auth: /cable?token=<access_token>

Integration notes:
- This is a skeleton, not a production SDK.
- Session persistence currently uses UserDefaults for simplicity; Keychain is better for production tokens.
- Refresh is serialized inside the API client actor so parallel 401s do not trigger duplicate refresh calls.
- Cable subscription uses the backend contract's channel map and hex_ids payload format.
- Incoming Action Cable frames are decoded best-effort; non-message frames are surfaced as plain text or control events.
