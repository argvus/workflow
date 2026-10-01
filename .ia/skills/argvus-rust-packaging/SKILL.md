---
name: argvus-rust-packaging
description: Rust workspace and Arch Linux packaging workflow for ARGVUS projects using skeleton-rs-pkg or skeleton-pkg.
---

# ARGVUS Rust and Packaging Workflow

Use this skill when working on Rust projects or Arch packaging.

## Skeletons

Rust + Arch packaging standard:

`skeleton-rs-pkg`

Arch-only packaging standard:

`skeleton-pkg`

Inspect the local project and compare with the appropriate skeleton before changing structure.

## Makefile

For projects standardized on an ARGVUS skeleton:

Do not modify the Makefile casually.

If the task is a skeleton alignment/refactor, the Makefile must remain identical
to the selected skeleton unless the user explicitly requests otherwise.

## Rust workspace

Preserve existing workspace organization.

Prefer:

- reusable logic in library/core crates;
- UI/binary entry points in application crates;
- no giant `main.rs`;
- explicit error types;
- no unnecessary dependencies.

## Build caching

Do not introduce packaging flows that force a clean Rust rebuild unnecessarily.

Release compilation should reuse Cargo target artifacts whenever possible.

Packaging should package existing release output rather than compile the full workspace
again unless makepkg semantics require it.

## Cargo

Use locked dependency resolution for release/package validation when project policy requires it.

Typical validation:

- `cargo fmt --all -- --check`
- `cargo check --workspace`
- `cargo clippy --workspace --all-targets --all-features -- -D warnings`
- `cargo test --workspace --locked`
- `cargo build --release --locked --workspace`

Adapt to the repository.

## PKGBUILD

Validate:

- package name;
- version;
- architecture;
- dependencies;
- optional dependencies;
- install paths;
- source;
- package();
- check();
- no writes to HOME.

Use:

`makepkg --printsrcinfo`

when applicable.

## Runtime dependencies

Distinguish:

- required runtime dependency;
- optional integration;
- build dependency;
- check dependency.

Do not make optional integrations mandatory without technical reason.

## Install paths

Use FHS/system paths coherently.

Typical ARGVUS paths include:

- `/usr/bin`
- `/usr/lib/argvus`
- `/usr/share/argvus`
- `/usr/share/applications`
- `/usr/share/backgrounds/argvus`

Non-CLI internal binaries should not automatically be installed into `/usr/bin`.

## Package output

When project conventions use `.pkg.tar.zst`, confirm package generation.

Do not declare success if only Cargo build passed but package generation failed.

## Validation

Also run:

- `git diff --check`
- repository Makefile targets
- staged install checks when relevant.

## Final report

Report:

- Cargo changes;
- dependency changes;
- packaging changes;
- install paths;
- build caching impact;
- tests;
- package output.