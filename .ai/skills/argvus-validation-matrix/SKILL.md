---
name: argvus-validation-matrix
description: Chooses the minimum validation commands for each kind of change in ARGVUS (Rust, Lua, shell, packaging, i18n, documentation, session integration). Use at the end of any implementation before reporting results, and when deciding which repositories to validate.
---

# ARGVUS Validation Matrix

Validate what the change touches and its direct consumers. Do not run expensive checks across every repository by default. Never report a check as passed unless it was run in this session, and report failures verbatim.

## Matrix

| Change | Minimum validation |
|---|---|
| Rust code (`.rs`, `Cargo.toml`) | `cargo fmt --all -- --check`, `cargo check --workspace`, `cargo clippy`, `cargo test` in the affected repository |
| Rust under `de/argvus/crates` | `make validate` in `de/argvus` (fmt, clippy `-D warnings`, workspace tests), or `cargo test -p <crate>` for a narrow change; see `argvus-monorepo` |
| Rust under `de/argvus/crates/argvus-greeter*` | `make validate` in `de/argvus`, plus `cargo build --profile greeter -p argvus-greeter` for the release-size build |
| Rust with `cargo build` or packaging impact | add `cargo build --release` and the `make` target the project defines |
| Lua (`hyprland.lua`, theme Lua, generated `hypr/*.lua`) | `luac -p` on each file, `stylua --check` |
| Shell still in use (packaging, hooks, install) | `sh -n`, `shellcheck` |
| PKGBUILD, Makefile, `.install` | `makepkg --printsrcinfo`, `make validate` (or the project's equivalent) |
| Strings visible to users | `argvus i18n validate` in the affected repository |
| Any change in `de/` with documentation impact | validate the affected `docs/` according to the project's own checks |
| Systemd units or session behavior | `systemctl --user daemon-reload`, check the unit state; report if no real session was available |
| Hyprland behavior (binds, reload, monitors) | reload the configuration and test the bind or action in a real session; report if not possible |
| Whole diff hygiene | `git diff --check` |

## Direct consumers

Changing a crate, script or config means validating its consumers too:

- a Rust library: the binaries that depend on it;
- a generated Lua file: the Hyprland config that loads it;
- a script: every caller found in the inventory of `argvus-shell-to-rust-migration`;
- a session unit: the units that depend on it.

## Reporting

For each check, state one of:

- passed (with the command);
- failed (with the output that matters);
- not run (with the reason, for example "no real session available").

Never write "should work" or "tested" for a check that was not run.

## Documentation

If the change affects documented behavior and the project has a `docs/` folder, validate those docs. Documentation is part of done. The project's `README.md` must not be left obsolete.
