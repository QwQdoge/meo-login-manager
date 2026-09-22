# Meo greeter motion contract

## Purpose

Meo Login Manager should feel continuous with Meo Session Lock while keeping authentication entirely inside Plasma Login Manager. The product language is Meo-owned: compact lock state, rounded credential surface, authenticated unlock morph, Meo Material roles and Meo typography.

The greeter does **not** load a logged-in shell runtime or previous-user configuration. Its implementation is native Qt/Kirigami QML and uses only Plasma Login Manager's existing models and `Authenticator`.

## Meo visual contract

The pre-login surface embeds a small presentation-only copy of the canonical MeoUI fallback roles because the display manager must not depend on a previous user's QML/plugin state.

Typography:

- Comfortaa: clock/display/brand text
- Roboto: normal controls, password field, labels and body UI
- Roboto Mono: technical/monospace text when needed
- Material Symbols Rounded: Meo symbolic icon face

Color roles follow the same MeoUI light/dark fallback role tables: primary and containers, surface hierarchy, outlines, error roles and Meo semantic success. New greeter-specific UI must consume these semantic roles rather than hard-coded decorative colors.

Motion uses the Meo transition layer's semantic timings. Authentication/session-start code must never sleep or wait merely to make presentation motion longer.

## Implementation

`MeoMain.qml` is a presentation wrapper around the existing `Main.qml`. `Main.qml` remains the upstream-compatible credential/user/session surface. `MeoGreeterTransition.qml` paints the Meo scrim and central morphing surface. `MeoGreeterTheme.qml` contains the self-contained Meo presentation tokens used before login.

Presentation states:

```text
ambient/collapsed
        |
        | trusted pointer/key interaction activates the existing greeter
        v
collecting/expanded
        |
        | Authenticator.login(...)
        v
submitting
   |          |
failed     succeeded
   |          |
   v          v
expanded   success morph -> greeter teardown/session start
```

The transition never calls `Authenticator.login`, starts a session, decides whether a password is correct, or overrides an authentication result. `onLoginSucceeded` only changes presentation state after the backend has already reported success.

## Privacy

The login surface may use system wallpaper/theme roles, the clock, display-manager user identities, keyboard/session selectors, battery state and power actions. It must not read a previous user's notifications, media, weather, wallet, home-directory theme configuration, or logged-in shell services.

The richer logged-in Meo Session Lock can show current-session information because it runs after a user session exists; that difference is intentional.

## Flicker limits

The QML transition can remove avoidable greeter-side hard cuts, but it cannot by itself guarantee a zero-black-frame handoff from the display-manager compositor to the newly started user compositor. Do not modify PAM, the daemon, or `src/frontend/startkde/` simply to prolong an animation.

The current safe sequence is:

1. keep the greeter window covering every display;
2. animate presentation only after `Authenticator` reports success;
3. allow the unchanged session-start path to own teardown;
4. let the Meo user session's own startup/splash/first-frame path cover later compositor handoff.

A future true cross-process retained-frame handoff requires a separately reviewed protocol/contract and must not be implemented as a timing sleep in the authentication path.

## Source provenance

The compact-to-expanded motion direction was initially informed by a GPL-compatible open-source lock implementation. The source reference and pinned revision remain in repository history/license documentation for attribution and reproducibility, but the product identity, colors, typography, naming and greeter implementation are Meo-owned. Third-party desktop-shell names are not used as runtime/product branding.

## Validation

Before merge:

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build -R meo-fork-boundary --output-on-failure
./build/bin/plasma-login-greeter --test
```

The exact greeter binary path is build-layout dependent; use the built `plasma-login-greeter --test` target if it is emitted elsewhere.

Mock-mode checks:

- initial/ambient surface covers every screen;
- interaction expands the central surface without replacing the password model;
- failed authentication returns focus to the existing password field;
- successful mock authentication starts only the presentation success motion;
- Meo colors and font families resolve correctly in both light and dark schemes;
- user/session/power controls still come from the upstream Plasma models;
- no previous-session notification/media/weather data is displayed;
- mixed-DPI and multi-monitor layouts remain fully covered.

A mock-mode pass does not authorize switching the real display manager on a development machine. Real login/session-start validation belongs in a VM first.
