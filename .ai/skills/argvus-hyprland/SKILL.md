---
name: argvus-hyprland
description: Hyprland, Lua configuration, generated config, keybindings, input, workspace, display, and reload workflow for ARGVUS.
---

# ARGVUS Hyprland Workflow

Use this skill for changes involving `argvus-hyprland` or generated Hyprland state.

## Principles

`argvus-hyprland` owns official defaults and Hyprland integration.

User tools such as Control Center should configure overrides/state, not rewrite
system-owned defaults directly.

## Lua

Preserve the current Lua configuration architecture.

Do not convert the entire config format without explicit reason.

Validate modified Lua with:

`luac -p`

when possible.

## Generated config

Prefer:

system defaults
+
user config/overrides
→ generated Lua
→ Hyprland.

Generated files belong under the existing ARGVUS generated config hierarchy.

Do not create competing generated directories.

## Keybindings

Keybindings should use:

stable semantic IDs
+
official actions
+
user key/modifier overrides.

Users should not edit arbitrary commands through ordinary shortcut settings unless
explicitly designed.

Preserve:

- flags;
- contexts;
- submaps;
- mouse bindings;
- repeating/locked behavior;
- callback semantics.

## Key normalization

Keep separate:

display representation
and
Hyprland/XKB canonical keysym.

Example:

display: `/`
canonical: `slash`

Conflict detection must use canonical form.

## Modifier display

Use one formatter.

When SUPER exists, display it first.

Preferred visual ordering:

SUPER
CTRL
ALT
Shift
Key.

## Input

Do not confuse:

Hyprland/libinput pointer speed
with
hardware DPI.

Generic input belongs to Hyprland/libinput.

Hardware capabilities may come from ratbagd or other appropriate backend.

## Reload

Use the established ARGVUS reload mechanism.

Do not simulate keyboard shortcuts to trigger reload.

Avoid restarting unrelated services if a targeted reload exists.

Do not spam reload operations during rapid UI changes.

## Fail-safe

Invalid generated config must not make the user unable to start the session.

Use:

- validation;
- atomic writes;
- fallback to defaults or previous valid generated file.

## Validation

Relevant checks may include:

- `make validate`
- `make build`
- `luac -p`
- Hyprland runtime tests
- `git diff --check`.

## Final report

Report:

- default/source model;
- generated path;
- reload mechanism;
- fallback;
- runtime validation;
- remaining compositor-specific limitations.