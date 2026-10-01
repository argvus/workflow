# Tooling, testing and dependencies

Additional guidance for `argvus-rust-code`. `SKILL.md` lists the validation
commands, the Clippy and rustfmt policy and the test naming rules. This file adds
configuration, test strategy and dependency hygiene. Use the validation policy of
the repository first.

## Daily loop

```sh
cargo fmt --all
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features
cargo doc --workspace --no-deps
```

If a command cannot be run in the current environment, say so and list what the
user should run and what to look for.

## Shared lint configuration

Configure lints in `Cargo.toml` (or `[workspace.lints]`) so everyone shares
them. Commit a `rustfmt.toml` only for non-default settings.

```toml
[lints.rust]
unsafe_code = "forbid"       # drop only where unsafe is justified
missing_docs = "warn"        # library crates

[lints.clippy]
all = { level = "warn", priority = -1 }
unwrap_used = "warn"         # library and core crates
expect_used = "warn"
dbg_macro = "warn"
todo = "warn"
```

- Add `clippy::pedantic` only when the project is ready, and silence individual
  noisy lints with a reason rather than disabling the group.
- Prefer `#[expect(lint, reason = "...")]` at the narrowest scope; it fails when
  the lint stops firing, so stale allowances disappear. Use `#[allow]` only with
  a comment when `expect` is unavailable.
- Treat warnings as errors in CI, not necessarily in the local loop.
- Do not introduce new crate-wide lint levels in an unrelated task.

## Where tests live

| Kind | Location | Purpose |
| --- | --- | --- |
| Unit | `#[cfg(test)] mod tests` at the bottom of the file | Logic, including private functions |
| Integration | `tests/*.rs` | The public API as a user sees it |
| Doc tests | `///` examples | Keep documentation correct |
| Benchmarks | `benches/` (criterion) | Performance regressions |

## Writing good tests

- One concept per test: arrange, act, assert. Tests are independent and
  deterministic: no ordering, wall-clock, network, real D-Bus, real Hyprland or
  real user config.
- Cover edge cases: empty input, boundaries, invalid input, error paths and
  Unicode for text.
- `unwrap()` / `expect()` are fine in tests. Tests may return
  `Result<(), Box<dyn Error>>` to use `?`.
- Use `tempfile` for filesystem tests; never write into the working directory or
  the real `$XDG_*` directories. Point the code under test at a temporary
  directory through its path parameters or environment variables.
- Isolate I/O behind traits or parameters and use small hand-written fakes
  instead of heavy mocking frameworks.
- Consider `proptest` for parsers and invariants, `insta` for snapshots of
  larger generated output (for example generated Hyprland configuration) and
  `assert_cmd` for end-to-end CLI tests.
- For async code use the runtime's test attribute and paused time instead of real
  sleeps.
- When fixing a bug, first write a failing test that reproduces it.

## Dependencies

`SKILL.md` lists the questions to ask before adding a crate. Also:

- Prefer well-maintained, widely used crates; check recent releases, open issues
  and license.
- Specify versions loosely (`"1"`, `"0.12"`) and commit `Cargo.lock` for
  binaries.
- Disable unneeded default features, and enable only the features that are used.
- Audit when the task touches dependencies: `cargo audit` (RustSec),
  `cargo deny` (licenses, duplicates, bans), `cargo machete` or `cargo udeps`
  (unused), `cargo tree -d` (duplicate versions).
- Share versions through `[workspace.dependencies]` to avoid drift.
- Report every dependency change in the final report.

## Cargo.toml hygiene

- Keep `description`, `license`, `repository` and `rust-version` (MSRV, only if
  one is promised) accurate.
- Use one edition for the whole workspace. Migrate editions with
  `cargo fix --edition` as a dedicated task.
- Pin the toolchain with `rust-toolchain.toml` only when reproducibility
  demands it.
- Release profile tuning (`lto`, `codegen-units`, `strip`, `panic`) affects
  packaging and build caching; coordinate it with `argvus-rust-packaging`.

## CI example

```yaml
name: ci
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: clippy, rustfmt
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --all -- --check
      - run: cargo clippy --workspace --all-targets --all-features -- -D warnings
      - run: cargo test --workspace --all-features --locked
      - run: cargo doc --workspace --no-deps
        env:
          RUSTDOCFLAGS: -D warnings
```

Add a matrix for the MSRV and for `--no-default-features` when publishing a
library.
