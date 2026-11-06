> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

## Workflow rules from the owner (override anything below)

- Commit directly on the repository's current/default branch (`main` unless the repo is deliberately on another working branch). Do not create feature branches or PR branches unless asked.
- After committing, push immediately. Do not ask for permission to commit or push, and do not leave finished work uncommitted or unpushed.
- Keep verification minimal: run only the quick check for the touched code (typecheck or the one relevant test). Do not run full suites or write extra tests unless asked.
- Do the whole task in one pass; do not stop to ask routine questions that have an obvious default.
- Never put secrets, tokens or credentials in code, logs or commits.

## MeoUI specification (read before UI work)

- People: https://meoarch.org/docs/ . Agents: https://meoarch.org/llms.txt , then the Markdown pages it lists; start with https://meoarch.org/docs/meoui/for-agents.md (decision tables and checklists).
- Window chrome and toolbar, where app settings live and their categories, About, and open-source credits: https://meoarch.org/docs/meoui/app-shell.md .
- The canonical source is MeoUI `docs/design/`; the site is generated from it. If they disagree, MeoUI wins. Propose rule changes there, not in this repository.

# Meo Login Manager agent rules

## Scope and fork boundary

This repository is the MeoArch-maintained Plasma Login thin fork. Keep Meo-specific changes narrow so upstream rebases remain reviewable.
The shared workspace rules in `../AGENTS.md` apply here. The fork baseline is pinned to `v6.7.5`; read `docs/MEO_FORK_POLICY.md` and `docs/MEO_SESSION_ENTRY_CONTRACT.md` before edits.

Keep greeter presentation in `src/frontend/greeter/`. Preserve upstream PAM, authentication, daemon, D-Bus, service, and session-start code unless a separately reviewed upstream security repair requires a change.

Inspect `git status`, the affected upstream/Meo files, and the nearest test before editing. Do not copy unrelated Meo shell/UI code into this fork to bypass an integration boundary. Read only task-relevant upstream/fork contracts.

## Validation matrix

For normal source changes, mirror `.github/workflows/arch-build.yml`:

1. Configure with CMake/Ninja and `BUILD_TESTING=ON`.
2. `cmake --build build --parallel 2`
3. `QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60`
4. For greeter changes, run the workflow's mock-authentication greeter smoke.

Use a staged install and `plasma-login-greeter --test` for the greeter validation path. Verify real PAM and Wayland login in the project VM before claiming release readiness.

For changes that expand or alter the Meo fork surface, also run:

`cmake -DPROJECT_SOURCE_DIR="$PWD" -DUPSTREAM_BASE=<reviewed-base> -P tests/verify-meo-fork-boundary.cmake`

Use a real reviewed base commit/ref. Never weaken the fork-boundary test just to make a change pass.

A successful build/offscreen test does not prove display-manager startup, PAM authentication, multi-monitor behavior, session launch, or a real login.

## Live-system boundary

Do not install this fork system-wide, modify PAM, disable/replace the active display manager, enable Plasma Login, log out, or reboot a live machine without explicit authorization. Prefer source, offscreen, staged, or VM validation first.

## Files and output

Keep project records outside source under the configured Meo records root when available, and generated build/evidence outside the repository where practical. Do not invent machine-specific paths.

Preserve unrelated dirty work and avoid destructive cleanup.

## MeoArch documentation map

- Docs site: https://meoarch.org/docs/ (MeoUI specification: app shell, settings pattern, page types, dynamic color, API lifecycle, localization). Agent entry points: https://meoarch.org/llms.txt and https://meoarch.org/docs/meoui/for-agents.md. The canonical source is the MeoUI repository `docs/`; if they disagree, the repository wins.
- Packaging and releases: https://github.com/QwQdoge/meo-repo - read its `AGENTS.md`, `docs/MEOARCH_IMPLEMENTATION_RUNBOOK.md`, `manifests/{beta,stable}/` and the "MeoArch repository release" workflow (https://github.com/QwQdoge/meo-repo/actions/workflows/release.yml).
- Release approval: the `sign-and-publish` and AUR jobs wait on the protected `release` Environment. After the owner confirms in chat, agents approve with `gh api -X POST repos/QwQdoge/meo-repo/actions/runs/<run>/pending_deployments -F environment_ids[]=<id> -f state=approved` (details in meo-repo `AGENTS.md`); the owner can also use Actions -> "Review deployments" -> `release`.
- Before tagging a component for release: its source archive must extract cleanly (no tracked build output such as `target/`, no absolute symlinks) and its CI must be green; tag the newest green commit.
- Other repositories: MeoUI (design system), meo-kde (Plasma shell), meo-ai (Meo AI), meo-api (cloud API), MeoArch-account (account app), MeoSettings, MeoArch-os-workspace (ISO/installer/repair), OmniStore, meo-login-manager, meo-repo (packages), meoarch-site (meoarch.org).

## Shared workspace rules (owner)

Source: the owner's local `projects/agent.md`, repeated here on purpose. These rules apply to every repository and win over generic caution in the rest of this file.

- "All repositories" means: the `projects` folder inside WSL Arch (`~/projects`), the Windows `projects` folder, and whatever `gh repo list QwQdoge` shows; confirm with `gh`.
- Reading a repository: `git pull` and `git push` first so it matches the cloud. If there are open PRs/branches, merge all of them. If a branch is large or needs a decision, ask once, then merge everything without asking again before each merge; after merging, ask whether to run tests. Exceptions: old dependency-bump branches and branches that are clearly unneeded.
- Work: update dependencies to the newest versions dynamically; only if a bug survives a real fix attempt, roll back and tell the user. Never create working branches: one shared workspace on the default branch, kept tidy. Push every piece of work to the cloud right away; always `git pull` then `git push`, no delay.
- Ask the user as little as possible: anything solvable by a simple attempt, or that matches the user's stated wishes, is done without asking. Ask only after repeated real attempts show the goal cannot be reached.
- Read every relevant document before working: local ones and https://meoarch.org/docs/ (agent entry: https://meoarch.org/llms.txt).
- Releases the owner asks for are authorized end to end (tag, manifest, dispatch, approve via `gh api .../pending_deployments`); do not stop for extra approvals.
- Never write personal or machine-specific details (usernames, absolute local paths, emails, VM or machine layout, secrets, resource ids) into repositories or published docs; keep them in local-only files (`~/.claude/CLAUDE.md`, the owner's local `projects/agent.md`).
