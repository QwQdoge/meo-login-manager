# Meo Login Manager agent rules

## Scope and fork boundary

This repository is the MeoArch-maintained Plasma Login thin fork. Keep Meo-specific changes narrow so upstream rebases remain reviewable.

Inspect `git status`, the affected upstream/Meo files, and the nearest test before editing. Do not copy unrelated Meo shell/UI code into this fork to bypass an integration boundary. Read only task-relevant upstream/fork contracts.

## Validation matrix

For normal source changes, mirror `.github/workflows/arch-build.yml`:

1. Configure with CMake/Ninja and `BUILD_TESTING=ON`.
2. `cmake --build build --parallel 2`
3. `QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60`
4. For greeter changes, run the workflow's mock-authentication greeter smoke.

For changes that expand or alter the Meo fork surface, also run:

`cmake -DPROJECT_SOURCE_DIR="$PWD" -DUPSTREAM_BASE=<reviewed-base> -P tests/verify-meo-fork-boundary.cmake`

Use a real reviewed base commit/ref. Never weaken the fork-boundary test just to make a change pass.

A successful build/offscreen test does not prove display-manager startup, PAM authentication, multi-monitor behavior, session launch, or a real login.

## Live-system boundary

Do not install this fork system-wide, modify PAM, disable/replace the active display manager, enable Plasma Login, log out, or reboot a live machine without explicit authorization. Prefer source, offscreen, staged, or VM validation first.

## Files and output

Keep project records outside source under the configured Meo records root when available, and generated build/evidence outside the repository where practical. Do not invent machine-specific paths.

Preserve unrelated dirty work and avoid destructive cleanup.
