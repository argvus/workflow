---
name: argvus-session-integration
description: Session startup, systemd user services, D-Bus, greetd, greeter, splash handoff, reload, and readiness workflow for ARGVUS.
---

# ARGVUS Session and System Integration Workflow

Use this skill when changes involve startup/session lifecycle or system services.

## Relevant projects

Commonly involved:

- argvus-session
- argvus-greeter
- argvus-theme-splash
- argvus-splash
- argvus-lock
- argvus-control-panel
- argvus-taskbar
- argvus-notifications
- argvus-portal
- argvus-power

Inspect only those relevant to the task.

## Startup flow

Trace the real flow before editing.

Potential stages:

greetd
→ greeter compositor
→ authentication
→ handoff
→ argvus-session
→ Hyprland
→ essential services
→ desktop ready.

Do not assume README flow is current.

## Readiness

Do not use arbitrary sleeps as the primary readiness mechanism.

Prefer:

- D-Bus signals;
- systemd state;
- sockets;
- ready FDs;
- explicit process readiness.

"Process spawned" is not equivalent to "user-visible ready".

## systemd

Avoid repeated start/restart storms.

When actions can happen rapidly:

- debounce/coalesce;
- serialize;
- avoid hitting start limits.

Inspect unit restart policy before adding retries.

## D-Bus

Use real introspection/API.

Do not invent interface/property names.

Keep UI calls asynchronous where appropriate.

## Reload

Use `argvus-sessionctl` or the established central mechanism when appropriate.

Avoid restarting all desktop components for a small setting if targeted reload exists.

## Greeter / splash handoff

Preserve visual continuity.

For handoff bugs, measure:

- authentication success;
- splash spawn;
- first frame;
- greeter exit;
- compositor exit;
- session start;
- desktop ready;
- splash exit.

Avoid black/blank gaps.

## Terminal lifecycle

If TUI is involved during login/handoff, inspect terminal cleanup carefully.

Normal exit and graphical handoff may require different visual handling.

Do not leave raw mode broken.

## Failure behavior

Session failure must not result in:

- permanent blank screen;
- stuck splash;
- unbounded wait.

Implement timeouts/fallback where necessary.

## Validation

Relevant tools may include:

- `systemctl --user status`
- `journalctl --user`
- D-Bus inspection
- runtime login tests
- repeated start/stop tests
- `sh -n`
- `shellcheck`
- Rust validation.

## Final report

Report:

- lifecycle before/after;
- readiness mechanism;
- services affected;
- runtime tests;
- failure fallback.