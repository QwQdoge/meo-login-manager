# Meo session-entry contract

This contract freezes the security and state boundary shared by the Meo lock
surfaces and Meo Login Manager. It is a P0 contract, not an implementation of a
new authentication protocol.

## Authorities

| Concern | Authority | Meo responsibility |
| --- | --- | --- |
| Login authentication, PAM conversation and session start | Plasma Login Manager upstream daemon and `Authenticator` | Render only upstream state and submit through the existing proxy. |
| Logged-in lock authentication, Plasma session | KScreenLocker and its upstream authentication path | Supply presentation/configuration only; keep the upstream security path. |
| Logged-in lock authentication, Meo Hyprland session | Wayland `ext-session-lock`/session-lock surface plus Quickshell PAM in the pinned Caelestia lock implementation | Keep the lock process resident, never infer authentication from animation/UI state, and retain a real emergency locker fallback. |
| Users, sessions, keyboard layout, Caps Lock, virtual keyboard and power actions | Existing Plasma Login Manager/KDE models | Bind to their real availability/state; never infer success from UI state. |
| Shared Meo-native visual controls and motion | MeoUI | Provide presentation primitives without credentials or OS authority. A pinned third-party lock implementation may retain its own visual stack and license. |
| Lock-screen configuration and desktop-session adaptors | MeoKDE/session integration | Read validated settings and degrade safely. |
| User editing and system-login writes | Meo Settings through its authorized backend | Preview, validate, restore defaults and commit atomically. |

QML must never log, persist, duplicate, expose through D-Bus, or retain a
password after a state change. Authentication success is authoritative only
when the active authentication backend reports it; the success animation is a
consequence, never a trigger.

## Authentication state machine

Every security surface exists before it presents content. A surface moves
through the following presentation states:

| State | Entry | Permitted transition |
| --- | --- | --- |
| `covered` | Window/surface is created for a screen | `ambient`, `collecting` |
| `ambient` | Idle clock/status content is visible | `collecting` after trusted input |
| `collecting` | The upstream credential control has focus | `submitting`, `ambient` |
| `submitting` | Existing authenticator received a request | `rejected`, `accepted` |
| `rejected` | Authenticator reported failure | `collecting` after bounded failure feedback |
| `accepted` | Authenticator reported success | upstream session/lock teardown only |

`submitting` rejects repeated submissions. Cancel, user/session change, screen
removal, greeter timeout and backend disconnect clear the authoritative
credential field before returning to `ambient` or `collecting`. Failure never
reveals the previous contents or changes the selected identity without a real
backend state change.

At the `v6.7.5` Plasma Login Manager baseline, the greeter exposes its shared
state through `GreeterState` (`userListPassword` and `userPromptPassword`). It
does not expose a PasswordSync symbol or a public PasswordSync contract.
Therefore Meo must not create a second password model: the existing
`GreeterState` remains the sole greeter-side state until an upstream replacement
is available and reviewed. A future upstream `PasswordSync` API may replace
that binding only if it preserves the same single-owner, clear-on-transition
rule.

The Hyprland lock is a separate logged-in process. Its credential exchange stays
inside the pinned Caelestia/Quickshell PAM implementation. Meo Login Manager
must not import that PAM object or share password state with it.

## Multi-screen contract

- A real full-screen security surface is created for every currently connected
  output; no non-active screen is a decorative mirror or may expose the
  desktop.
- For the login greeter, one `activeAuthenticationScreen` owns keyboard focus.
  Its selection is an opaque screen key plus `auto`, `fixed-primary`, or
  `follow-interaction` policy. User-configured keys are resolved through KDE's
  screen model, never through coordinates or a guessed primary display.
- A pointer/touch interaction may change the active login screen. The old and
  new panels use a bounded fade-through; their windows remain in place.
  Password state stays with the upstream single owner, not with either screen.
- If the active screen disappears, the first remaining eligible screen becomes
  active immediately and receives focus. If no screens remain, the session
  stays covered and waits for a new screen; it never falls back to desktop.
- Each security surface responds to its own geometry, orientation, scale and
  DPMS state. Hot-plug, sleep/DPMS recovery, negative coordinates and mixed DPI
  are test cases, not layout assumptions.

The login greeter continues to use the upstream Plasma Login Manager Layer
Shell security surface. A Plasma logged-in session continues to use
KScreenLocker. A Meo Hyprland session uses the compositor's Wayland
session-lock protocol through the pinned Quickshell/Caelestia implementation.
Meo does not invent a decorative always-on-top window and call it a lock.

## Configuration, privacy and fallback

The formal version-one schema is owned by MeoKDE at
`docs/schemas/meo-session-entry-v1.schema.json`. It distinguishes a user
`lockscreen` document from an authorized system `login` document. The Meo
login greeter uses only system-managed wallpaper/theme roles and pre-login
system state; it reads no media, notifications, weather, KWallet, or previous
user session data.

A rich logged-in lock profile may show notification content, album artwork,
city-level cached weather, current-session media, and output volume because
those sources belong to the already authenticated session. Those sources are
absent from the greeter. External data is asynchronous and may not delay
authentication.

If a Plasma lock theme cannot load, KScreenLocker must use the configured KDE
fallback theme. If the Hyprland Meo/Caelestia lock process cannot be reached,
`meo-lock` must invoke a real emergency locker (`hyprlock`) rather than return
success or leave the desktop exposed. If the Meo greeter visual layer cannot
load, the upstream-compatible greeter/authentication path remains the recovery
target. A fallback must never be represented as successful authentication.
