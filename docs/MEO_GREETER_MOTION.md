# Meo greeter motion contract

## Purpose

The Meo login greeter should feel continuous with the logged-in Meo/Caelestia
lock surface without moving authentication into third-party QML. The visual
reference is Caelestia Shell's lock transition: a compact lock shape expands
into the credential surface and, after authoritative authentication succeeds,
contracts into an unlock shape while the background fades away.

Reference project:

- https://github.com/caelestia-dots/shell
- reference commit: `20e625d6bf1a9d0bb7625a4bb814797d187b075d`
- reference files: `modules/lock/LockSurface.qml` and `modules/lock/Center.qml`

The greeter does **not** copy or load the Caelestia runtime. Its implementation
is native Qt/Kirigami QML and uses only Plasma Login Manager's existing models
and `Authenticator`.

## Implementation

`MeoMain.qml` is a presentation wrapper around the existing `Main.qml`.
`Main.qml` remains the upstream-compatible credential/user/session surface.
`MeoGreeterTransition.qml` paints only a background scrim and central morphing
surface.

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

The transition never calls `Authenticator.login`, starts a session, decides
whether a password is correct, or delays/overrides an authentication result.
`onLoginSucceeded` only changes the presentation state after the upstream
backend has already reported success.

## Privacy

The login surface may use system wallpaper/theme roles, clock, user identities
provided by the display manager, keyboard/session selectors, battery state and
power actions. It must not read the previous user's notifications, media,
weather, KWallet, home-directory configuration, or Caelestia user services.

The rich logged-in lock screen can show current-session information because it
runs after a user session exists; that difference is intentional.

## Flicker limits

The QML transition can remove avoidable greeter-side hard cuts, but it cannot by
itself guarantee a zero-black-frame handoff from the display-manager compositor
to the newly started user compositor. Do not modify PAM, the daemon, or
`src/frontend/startkde/` simply to prolong an animation.

The current safe sequence is:

1. keep the greeter window covering every display;
2. animate presentation only after `Authenticator` reports success;
3. allow the unchanged upstream session-start path to own teardown;
4. let the user session's own startup/splash/first-frame path cover any later
   compositor handoff.

A future true cross-process retained-frame handoff requires a separately
reviewed protocol/contract and must not be implemented as a timing sleep in the
authentication path.

## Validation

Before merge:

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build -R meo-fork-boundary --output-on-failure
./build/bin/plasma-login-greeter --test
```

The exact greeter binary path is build-layout dependent; use the built
`plasma-login-greeter --test` target if it is emitted elsewhere.

Mock-mode checks:

- initial/ambient surface is covered on every screen;
- interaction expands the central surface without replacing the password model;
- failed authentication returns focus to the existing password field;
- successful mock authentication starts only the presentation success motion;
- user/session/power controls still come from the upstream models;
- no previous-session notification/media/weather data is displayed;
- mixed-DPI and multi-monitor layouts remain fully covered.

A mock-mode pass does not authorize switching the real display manager on a
development machine. Real login/session-start validation belongs in a VM first.
