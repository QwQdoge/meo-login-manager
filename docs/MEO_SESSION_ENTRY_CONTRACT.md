# Meo session-entry contract

This contract freezes the security and state boundary shared by the future Meo
lock screen and Meo Login Manager.  It is a P0 contract, not an implementation
of a new authentication protocol.

## Authorities

| Concern | Authority | Meo responsibility |
| --- | --- | --- |
| Login authentication, PAM conversation and session start | Plasma Login Manager upstream daemon and `Authenticator` | Render only upstream state and submit through the existing proxy. |
| Logged-in lock authentication | KScreenLocker and its upstream authentication path | Supply a Look-and-Feel lock-screen theme only. |
| Users, sessions, keyboard layout, Caps Lock, virtual keyboard and power actions | Existing Plasma Login Manager/KDE models | Bind to their real availability/state; never infer success from UI state. |
| Shared visual controls and motion | MeoUI | Provide presentation primitives without credentials or OS authority. |
| Lock-screen configuration and KDE data adaptors | MeoKDE | Read validated settings and degrade safely. |
| User editing and system-login writes | Meo Settings through its authorized backend | Preview, validate, restore defaults and commit atomically. |

QML must never log, persist, duplicate, expose through D-Bus, or retain a
password after a state change.  Authentication success is authoritative only
when the upstream backend reports it; the success animation is a consequence,
never a trigger.

## Authentication state machine

Every security surface exists before it presents content.  A surface moves
through the following presentation states:

| State | Entry | Permitted transition |
| --- | --- | --- |
| `covered` | Window/surface is created for a screen | `ambient`, `collecting` |
| `ambient` | Idle clock/status content is visible | `collecting` after trusted input |
| `collecting` | The upstream credential control has focus | `submitting`, `ambient` |
| `submitting` | Existing upstream authenticator received a request | `rejected`, `accepted` |
| `rejected` | Upstream authenticator reported failure | `collecting` after bounded failure feedback |
| `accepted` | Upstream authenticator reported success | upstream session/lock teardown only |

`submitting` rejects repeated submissions.  Cancel, user/session change,
screen removal, greeter timeout and backend disconnect clear the upstream
credential field before returning to `ambient` or `collecting`.  Failure never
reveals the previous contents or changes the selected identity without an
upstream state change.

At the `v6.7.5` baseline, Plasma Login Manager exposes its shared greeter
state through `GreeterState` (`userListPassword` and
`userPromptPassword`).  It does not expose a PasswordSync symbol or a public
PasswordSync contract.  Therefore Meo must not create a second password model:
the existing `GreeterState` remains the sole greeter-side state until an
upstream replacement is available and reviewed.  A future upstream
`PasswordSync` API may replace that binding only if it preserves the same
single-owner, clear-on-transition rule.

## Multi-screen contract

- A real full-screen security surface is created for every currently connected
  `QScreen`; no non-active screen is a decorative mirror or may expose the
  desktop.
- One `activeAuthenticationScreen` owns keyboard focus.  Its selection is an
  opaque screen key plus `auto`, `fixed-primary`, or `follow-interaction`
  policy.  User-configured keys are resolved through KDE's screen model, never
  through coordinates or a guessed primary display.
- A pointer/touch interaction may change the active screen.  The old and new
  panels use a 250 ms fade-through; their windows remain in place.  Password
  state stays with the upstream single owner, not with either screen.
- If the active screen disappears, the first remaining eligible screen becomes
  active immediately and receives focus.  If no screens remain, the session
  stays covered and waits for a new screen; it never falls back to desktop.
- Each surface responds to its own geometry, orientation, scale and DPMS state.
  Hot-plug, sleep/DPMS recovery, negative coordinates and mixed DPI are test
  cases, not layout assumptions.

The login greeter continues to use the upstream Layer Shell security surface;
the logged-in surface continues to be KScreenLocker.  Meo does not introduce a
new privileged window type.

## Configuration, privacy and fallback

The formal version-one schema is owned by MeoKDE at
`docs/schemas/meo-session-entry-v1.schema.json`.  It distinguishes a user
`lockscreen` document from an authorized system `login` document.  The login
document permits only system-managed wallpaper assets and city-level cached
weather; it never reads a previous user's session data.

The safe defaults are: notifications show a count only; complete notification
content, application names, album artwork and precise weather location are
off; media and weather disappear when their provider is unavailable or times
out.  External data is asynchronous and may not delay authentication.

If a Meo lock-screen theme cannot load, KScreenLocker must use the configured
KDE fallback theme.  If the Meo greeter visual layer cannot load, the upstream
greeter QML remains usable.  A fallback is reported to the authorized settings
backend after the surface is safe; it must not present an in-band error that
blocks authentication.
