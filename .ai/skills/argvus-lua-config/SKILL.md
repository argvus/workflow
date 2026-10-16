---
name: argvus-lua-config
description: Lua configuration for ARGVUS on Hyprland 0.56.2. Use when editing hyprland.lua, theme.lua files, generated Lua files under generated/hypr/ (keybindings, input, window-rules, monitors), hl.* calls, keybinding definitions, or the Rust code that writes Lua (argvus-config project.rs and lib.rs parsers). Lua has no standalone runtime in ARGVUS; it runs only inside Hyprland.
---

# ARGVUS Lua Configuration

Lua in ARGVUS is the Hyprland configuration layer. It is not a general scripting language for the system. Use it for binds, rules, submaps, event hooks and reading generated state. Put system logic in Rust.

## Source of truth

- Source: `de/argvus-hyprland/src/usr/share/argvus/hyprland/config/hyprland.lua`, the theme files and `keybindings.json`.
- Generated (derived, never edit by hand): `$ARGVUS_CONFIG_HOME/argvus/data/generated/hypr/*.lua`, written by `de/argvus-config/src/project.rs`.
- User overrides: `data/hypr/{monitors,rules,bindings,user}.lua`.
- `keybindings.json` alone does not create a bind. The Lua bind must exist.

## Validation (required before reporting Lua work)

- `luac -p <file>` for every Lua file changed or generated.
- `stylua --check` with the project's `.stylua.toml`.
- Confirm every `hl.*` call against the stubs in `/usr/share/hypr/stubs/` for the 0.56.2 API. Do not rely on memory of the API.
- When Rust writes Lua, validate the generated output with `luac -p` before replacing the previous file. On failure, keep the previous file and report the error.

## Runtime loading

- Load generated and user files with `pcall(dofile, ...)`. A broken optional file must not stop the whole configuration.
- Report the failing path and message through the existing notification or log path.
- Never use `dofile` without `pcall` for user override files.

## Calling out

- Prefer `hl.dsp.*`, `hl.monitor`, `hl.get_*` and `hl.on(...)` over shell.
- A shell command that calls `hyprctl eval`, `hyprctl dispatch`, `hyprctl keyword` or `hyprctl reload` back into the compositor creates a loop. Do not add new ones. Remove an existing one when the task touches it.
- Do not add `io.popen` in the configuration load path without a reason. Prefer reading generated files.
- Any new shell-out must reference an existing `argvus <subcommand>` route, not a new `.sh` script.

## Keybindings

- Keep ids, categories and actions consistent with `keybindings.json`.
- Update the cheatsheets in `de/argvus-hyprland/src/usr/share/argvus/hyprland/docs/cheatsheets/` when a shortcut changes.
- Test the bind after reload, not only the syntax.

## Checklist

1. Is the file source or generated? Edit the source only.
2. `luac -p` passes on every changed or generated file.
3. `stylua --check` passes.
4. Every new `hl.*` call exists in the 0.56.2 stubs.
5. No new shell loop back into `hyprctl`.
6. Optional files load through `pcall`.
7. Keybinding changes are reflected in `keybindings.json`, the bind and the cheatsheets.
