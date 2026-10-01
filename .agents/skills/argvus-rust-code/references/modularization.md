# Modularization and project structure

Additional guidance for `argvus-rust-code`. `SKILL.md` covers the basics (modules
by responsibility, no `utils.rs` dumping grounds, narrow visibility). This file
adds the layout and refactoring mechanics. Preserve the workspace organization
that the project already has (see `argvus-rust-packaging`).

## Contents

- Vocabulary
- When to split
- Binary plus library layout
- Module file layout
- Visibility and public API
- Layering
- Workspaces
- Features
- Example trees
- Refactoring a large file

## Vocabulary

- Package: what `Cargo.toml` describes.
- Crate: a compilation unit (library or binary).
- Module: a namespace inside a crate and the unit of privacy.
- Workspace: several packages sharing a lockfile and target directory.

Use modules first. Create a new crate only for independent reuse or versioning,
faster incremental builds, or a hard dependency boundary.

## When to split

Split by responsibility and reason to change, not by line count alone. Signs a
file should be divided:

- it mixes layers (parsing, business logic, I/O, rendering);
- section comments act as dividers;
- unrelated tests live next to each other;
- parts change for different reasons or at different speeds;
- parts have clearly different dependency needs.

A file beyond roughly 400-600 lines or a function beyond roughly 50 lines
deserves a look, but a cohesive 700-line module is better than three artificial
ones. Do not split by kind (`structs.rs`, `enums.rs`, `traits.rs`); split by
feature or domain concept.

## Binary plus library layout

Keep `main.rs` a thin adapter and put the logic in a library target of the same
package so it is testable and reusable:

```text
app/
├── Cargo.toml
├── src/
│   ├── main.rs     # parse args, call run(), map the error to an exit code
│   ├── lib.rs      # module declarations, crate docs, re-exports
│   ├── cli.rs      # argument definitions
│   ├── config.rs
│   └── error.rs
└── tests/          # integration tests using the public library API
```

```rust
fn main() -> anyhow::Result<()> {
    let args = app::cli::parse();
    app::run(args)
}
```

## Module file layout

Prefer `foo.rs` plus a `foo/` directory over `foo/mod.rs`; it avoids many tabs
named `mod.rs`. Follow the layout already used by the project if it differs.

```text
src/
├── storage.rs        # declares `mod sqlite; mod memory;` and the public trait
└── storage/
    ├── sqlite.rs
    └── memory.rs
```

- Order inside a parent file: `//!` docs, child `mod` declarations, re-exports,
  then items.
- Group `use` statements: `std`, external crates, then `crate::` / `super::`.
- Avoid glob imports except `use super::*;` in tests and deliberate preludes.

## Visibility and public API

| Visibility | Meaning |
| --- | --- |
| (none) | Private to the module |
| `pub(super)` | Visible to the parent module |
| `pub(crate)` | Visible across the crate; default for "internal but shared" |
| `pub` | Part of the public API |

- Design the public API deliberately and re-export the types users need at the
  crate root, hiding the internal tree so it can be reorganized freely.
- Do not expose dependency types in a public API unless you commit to that
  dependency's version.
- Keep fields private when invariants exist; use `#[non_exhaustive]` and sealed
  traits to leave room for growth.

## Layering

Dependencies should flow one way:

```text
cli / ui  ->  application logic  ->  domain types  ->  (nothing)
                     |
              infrastructure (filesystem, D-Bus, processes) behind traits
```

- Domain types and pure logic must not know about the terminal, the filesystem,
  D-Bus or Hyprland.
- Put I/O behind small traits or function parameters so logic can be tested with
  hand-written fakes.
- Avoid module cycles; extract the shared part into a third module.
- Pass dependencies explicitly instead of using globals or `static mut`. When
  global state is unavoidable use `OnceLock` / `LazyLock` behind a function.
- Keep error types close to the layer that produces them and convert at the
  boundaries with `impl From<LowError> for HighError`.

## Workspaces

Use a workspace when there are several related crates (core, CLI, TUI, shared
types). Keep the direction explicit: core crates depend on nothing internal;
CLI and TUI crates depend on core, never the reverse.

```toml
[workspace]
resolver = "2"
members = ["crates/*"]

[workspace.package]
edition = "2021"
license = "MIT OR Apache-2.0"
version = "0.1.0"

[workspace.dependencies]
anyhow = "1"
serde = { version = "1", features = ["derive"] }

[workspace.lints.rust]
unsafe_code = "forbid"
```

A member opts in with `serde.workspace = true`, `edition.workspace = true` and
`[lints] workspace = true`. Keep every member on the same edition and do not
change the edition or resolver of an existing project as a side effect of an
unrelated task.

## Features

- Features must be additive: enabling one never removes or breaks behavior.
- Use them to make heavy or optional dependencies opt-in.
- Keep the default set small, document each feature in the crate docs and test
  `--no-default-features` and `--all-features` in CI.

## Example trees

Small CLI:

```text
src/
├── main.rs
├── lib.rs
├── cli.rs          # clap definitions
├── commands.rs     # + commands/{add,list}.rs
├── config.rs
└── error.rs
```

TUI (ratatui):

```text
src/
├── main.rs
├── app.rs          # state and update logic, no rendering
├── action.rs       # enum of user intents
├── event.rs        # input / tick / worker events and the event loop
├── terminal.rs     # setup, teardown guard, panic hook
├── ui.rs           # rendering from &App only
└── ui/
    ├── list.rs
    └── popup.rs
```

## Refactoring a large file

1. Make sure tests pass first; add characterization tests if they are missing.
2. Identify clusters of related items and their dependencies.
3. Move one cluster at a time into a new module, compiling after each move.
4. Narrow visibility after the move: anything used only inside the new module
   goes back to private.
5. Fix imports and run `cargo fmt` and `cargo clippy`.
6. Keep pure moves and renames in separate commits from behavior changes so
   reviewers can verify that nothing changed.

Do not perform this kind of restructuring during unrelated feature work; see the
refactoring policy in `SKILL.md`.
