# Meo Login Manager thin-fork policy

## Baseline and purpose

`meo/6.7` starts at upstream Plasma Login Manager `v6.7.5`
(`e63894e7923db053413915ea582db2757303ca8f`).  The `upstream` remote remains
the only upstream source.  This repository changes presentation and Meo-owned
configuration integration; it does not become a replacement authentication or
session-management stack.

The branch must continue to build the upstream service identity
`plasmalogin`, use its PAM configuration and preserve the existing display
manager D-Bus contracts.  A renamed Meo Arch package may provide, conflict
with and replace `plasma-login-manager`, but the installed runtime identities
remain upstream-compatible.

## Reviewed change surface

Meo changes are limited to these locations:

- `src/frontend/greeter/` for the visual greeter, its mock mode and the
  presentation-only screen coordinator;
- `src/frontend/kcm/` only for a compatibility handoff to Meo Settings, not a
  second configuration authority;
- `packaging/`, `docs/`, `tests/`, and the narrowly scoped CMake registration
  required for those changes.

The following paths are protected upstream security/runtime interfaces and
must not be modified by Meo feature work: `data/pam/`, `data/interfaces/`,
`services/`, `src/auth/`, `src/common/`, `src/daemon/`, `src/helper/`, and
`src/frontend/startkde/`.  A security or upstream compatibility repair in one
of them needs a separately reviewed upstream patch, a rationale, and a new
baseline decision before it can enter this fork.

`ctest -R meo-fork-boundary --output-on-failure` enforces the documented
surface against `v6.7.5` in a Git checkout.  It always checks that this policy
and the session-entry contract are present; source archives skip only the
Git-diff portion.

## Upstream synchronization

1. Fetch `upstream`, choose a released `v6.7.x` tag, and record its full
   commit before changing this branch.
2. Review upstream changes to every protected path first.  Take authentication,
   PAM, daemon, D-Bus, service and session-start fixes intact; do not manually
   reimplement them in QML.
3. Rebase or merge the reviewed tag, resolve only Meo presentation/KCM changes,
   then run the boundary CTest and the upstream build/test suite.
4. Run the greeter's upstream mock mode (`plasmalogin-greeter --test`) before
   a VM test.  No source check or mock test authorizes a real display-manager
   switch on a user's machine.

## Explicit non-goals

The fork never stores passwords, synthesizes a PAM conversation, replaces the
daemon, changes service IDs, reads a previous user's media data, or enables a
third-party QML plugin in the greeter.  Login weather is a separately approved
system-level cache feature; it is absent until that cache and its privacy
policy are implemented.
