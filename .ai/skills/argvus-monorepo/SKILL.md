---
name: argvus-monorepo
description: Map of the consolidated ARGVUS Rust workspace at de/argvus (crates, the argvus CLI dispatcher, in-process subcommands, private executables, the separate greeter workspace, retired repositories and their new locations). Use when a task touches any Rust code under de/argvus, when a skill or document names a retired repository such as argvus-config, argvus-i18n or argvus-control-center, or when a caller must be pointed at argvus <command>.
---

# ARGVUS Monorepo (`de/argvus`)

Most desktop Rust code lives in one Cargo workspace at `de/argvus`. Read this skill before
changing a crate there, a caller of an `argvus` subcommand, or a document that names a
retired repository. The workspace `Cargo.toml` is the source of truth for members.

## Layout

- Workspace root: `de/argvus/Cargo.toml`, `exclude = ["greeter"]`.
- Command crates: `crates/<name>`, one per tool (for example `argvus-config`, `argvus-i18n`,
  `argvus-control-center`, `argvus-terminal`).
- Shared logic: `crates/<name>-core` (for example `argvus-i18n-core`, `argvus-network-core`).
  Put reusable logic in `-core` and keep the command crate thin.
- Dispatcher: `crates/argvus-cli` (`main.rs`, `commands.rs`, `dispatch.rs`). Its public
  entry point is `argvus <command>`.
- Greeter: `crates/argvus-greeter`, a member of the root workspace (built with
  `cargo build --profile greeter`, output in `target/greeter/`). Its DRM handoff helper is
  `crates/argvus-greeter-handoff`. Both are packaged inside the `argvus` package.
- Docs: `de/argvus/docs/{en,pt-br}/components/<repository>/` for user pages and
  `de/argvus/docs/internal/<repository>/` for developer notes.

## Dispatch model

`argvus <command>` resolves a subcommand in one of three ways:

1. **In-process** (a library `run_command` in the crate, no separate executable): `config`,
   `i18n`, `keys` (and `gpg`), `projects`, `terminal`, `system-monitor`, `network` (and
   `bluetooth`), `widget-telemetry` (`block`, `toggle`), `tui-terminal`, `setup`.
2. **Private executable**: the dispatcher starts a named binary from the commands
   directory (`/usr/lib/argvus/commands`, or `ARGVUS_COMMANDS_DIR`). The table lives in
   `crates/argvus-cli/src/commands.rs`. Current entries include `control-center`,
   `taskbar-calendar`, `removable-devices`, `session`, `greeter`, `accounts`, `firewall`,
   `notifications`, `displayctl`, `launcher`, `game-snake` and others. Read the table
   before assuming a name exists.
3. **Script route**: Hyprland script commands map to `<domain>/sh/<script>.sh` under the
   ARGVUS data root (`ScriptRoute` in the same file).

Paths are never built from user input: only names in the closed tables are reachable.

## Retired repositories

These repositories are retired. Their code lives in the workspace and they must not be
modified. Their `de/retiree/<name>` copies are read-only history.

| Retired repository | Now |
|---|---|
| `argvus-config` | `crates/argvus-config`, `argvus config` |
| `argvus-i18n` | `crates/argvus-i18n` and `argvus-i18n-core`, `argvus i18n` |
| `argvus-keys` | `crates/argvus-keys`, `argvus keys` |
| `argvus-projects` | `crates/argvus-projects`, `argvus projects` |
| `argvus-terminal` | `crates/argvus-terminal`, `argvus terminal` |
| `argvus-system-monitor` | `crates/argvus-system-monitor`, `argvus system-monitor` |
| `argvus-network` | `crates/argvus-network-commands`, `argvus network` |
| `argvus-widget-telemetry` | `crates/argvus-widget-telemetry-*`, `argvus widget-telemetry` |
| `argvus-tui` | `crates/argvus-tui` (library, used by the greeter); `argvus tui-terminal` is `crates/argvus-tui-terminal` |
| `argvus-control-center` | `crates/argvus-control-center*`, `argvus control-center` |
| `argvus-taskbar-calendar` | `crates/argvus-taskbar-calendar`, private executable `taskbar-calendar` |
| `argvus-removable-devices` | `crates/argvus-removable-devices`, private executable `removable-devices` |
| `argvus-loading-theme` | `crates/argvus-loading-theme*`; the overlay stays at `/usr/lib/argvus/loading-theme/splash` |
| `argvus-themes` | `crates/argvus-theme` (shared theme logic); each official theme is its own `de/argvus-theme-*` repository |

Repositories that keep their own executables and are not part of the workspace:
`argvus-accounts` (runs as root through `pkexec`), `argvus-firewall`, `argvus-game-snake`
(independent and optional, depends on `../argvus/crates/...` by path).

## Rules

- Do not add a caller to `/usr/lib/argvus/commands/argvus-*` in new code. Use
  `argvus <command>`. Callers that must start before `PATH` is set (systemd units, greetd)
  use `/usr/bin/argvus <command>`.
- Inside `argvus` itself, call the running binary (`current_exe()`) or `argvus` from `PATH`,
  never a sibling file built from the commands directory.
- Systemd unit names keep their historical names (for example `argvus-config.service`);
  renaming a unit is a session change, not a monorepo change.
- Changing a crate's public behaviour means checking every direct caller in `de/`:
  `rg "argvus (config|i18n|...)"` and `rg "argvus-<name>"` in `de/` (excluding `de/retiree`).
- Stale names found in documentation or skills must be replaced by the table above.

## Validation

- Workspace: `make validate` in `de/argvus` (fmt, clippy with `-D warnings`, tests). For
  a narrow change, `cargo test -p <crate>` plus `cargo clippy -p <crate>`.
- Greeter: covered by `make validate` in `de/argvus` like every other crate.
- Packaging: `makepkg --printsrcinfo` in `de/argvus/packaging/arch/{ci,local}/PKGBUILD`. See
  `argvus-rust-packaging`.
- Build disk pressure: `/tmp` can have a small quota; use
  `CARGO_INCREMENTAL=0 CARGO_PROFILE_DEV_DEBUG=0` when a build fails with `EDQUOT`.

## Related skills

- `argvus-rust-code` for coding rules.
- `argvus-rust-packaging` for the PKGBUILD and the three split packages.
- `argvus-shell-to-rust-migration` when a shell script moves into a subcommand.
- `argvus-documentation` for the `docs/` pages of the workspace.
