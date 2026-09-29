# Meo Login Manager agent rules

## Scope and fork boundary

This repository is the MeoArch-maintained Plasma Login thin fork. Keep Meo-specific changes narrowly scoped and preserve upstream structure so future rebases remain reviewable.

Before editing, inspect `git status`, the affected upstream/Meo files, and the fork-boundary test. Do not copy unrelated Meo shell/UI code into this repository merely to avoid an integration boundary.

## Validation

For normal source changes, mirror `.github/workflows/arch-build.yml`:
- configure with CMake/Ninja and `BUILD_TESTING=ON`
- `cmake --build build --parallel 2`
- `QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60`
- for greeter changes, run the workflow's mock-authentication greeter smoke

For fork-surface changes, also run:
`cmake -DPROJECT_SOURCE_DIR="$PWD" -DUPSTREAM_BASE=<review-base> -P tests/verify-meo-fork-boundary.cmake`
using a real reviewed base commit. Do not weaken the boundary test to make an unrelated change pass.

A successful offscreen build/test does not prove display-manager startup, PAM authentication, multi-monitor behavior, or a real login session.

## Live-system safety

Do not install this fork system-wide, disable SDDM, enable Plasma Login, modify PAM, change the active display manager, log out, or reboot a live machine unless the user explicitly authorizes that exact action. Prefer VM/offscreen validation first.

Keep plans/audits outside the source tree under the configured Meo project-record root when available, and keep generated build/evidence outside the repository where practical. Preserve unrelated dirty work and avoid destructive cleanup.
