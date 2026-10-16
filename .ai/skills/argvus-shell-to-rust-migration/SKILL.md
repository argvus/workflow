---
name: argvus-shell-to-rust-migration
description: Migrates ARGVUS runtime shell scripts (.sh) to Rust, as subcommands of the argvus CLI or as crate code, without breaking callers. Use when replacing any runtime .sh script, changing a systemd ExecStart, an exec_cmd path in Lua, a waybar or control-center call, or when deleting a script.
---

# ARGVUS Shell to Rust Migration

Goal: runtime logic lives in Rust. Shell stays only for packaging, Makefiles and install hooks. Migrate one script per change. Each change must leave no dual path.

## Steps

### 1. Inventory every caller

Search the whole workspace under `de/` before touching the script. Include:

- Lua: `exec_cmd`, `_sh(...)`, `io.popen` in `argvus-hyprland`;
- systemd units: `ExecStart`, `ExecReload`, `ExecStartPre` in `*.service`;
- waybar: `exec`, `on-click`, `on-scroll` in `argvus-waybar` and `argvus-widget-telemetry`;
- Rust callers in `argvus-control-center*` (for example `theme-switch`, `sessionctl`, `effects-toggle`, `monitor-switch`);
- other shell callers, keybind helpers, `.install` hooks and Makefiles;
- tests in `tests/`.

Write the list down. Every entry must be updated or justified in the same change.

### 2. Record the external contract

For each script, document:

- arguments and their order, including defaults;
- environment variables read;
- exit codes;
- stdout format (text, JSON, silent) that callers parse;
- side effects (files written, services restarted, `hyprctl` calls, notifications);
- paths read or written, following the user configuration contract (XDG for user state, system paths for defaults).

The Rust version must keep this contract unless the task explicitly changes it.

### 3. Implement in Rust

- Choose the home: a subcommand of the `argvus` CLI, or a crate that already owns the domain. Check whether the repository already has Rust code (`Cargo.toml`) before deciding.
- Separate parsing (CLI), domain logic and side effects. Domain logic must be testable without Hyprland, systemd or a filesystem.
- Replace `sed` and `awk` over config with structured parsing or the existing config tooling (`argvus config`).
- Replace `hyprctl` calls with `hl.*` from Lua or with the Hyprland socket, not with new shell pipelines.
- Visible strings go through `argvus-i18n`.
- Add `#[test]` for the migrated logic, including the exit codes and output format from step 2.

### 4. Switch every caller

Update every caller from step 1 to the new route, in the same change.

### 5. Delete the old script

Remove the `.sh` in the same change, after every caller is switched. Do not keep a fallback copy. Do not keep an unused wrapper.

Exception: during a staged migration, the Lua route may delegate to the old `.sh` for one stage. Record this delegation explicitly, and remove it in the next stage.

### 6. Validate

- Rust: `cargo fmt --all -- --check`, `cargo check --workspace`, `cargo clippy`, `cargo test`.
- Units: `systemctl --user daemon-reload` and check the unit still starts in a session (only when the environment allows it; report if it could not run).
- Lua callers: `luac -p`.
- Packaging: `make validate` and `makepkg --printsrcinfo` when the Makefile or PKGBUILD listed the script.
- Remaining shell: `sh -n` and `shellcheck`.

### 7. Report

Report which callers changed, which contract points were kept, what was deleted, and what was not validated in a real session.

## Do not

- Do not change the Makefile or PKGBUILD structure of a skeleton project without explicit approval.
- Do not migrate several scripts in one change.
- Do not add a new runtime Lua interpreter to run system scripts.
- Do not leave both the `.sh` and the Rust route active for the same action.
