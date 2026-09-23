---
name: argvus-rust-code
description: Rust coding conventions and implementation quality rules for ARGVUS. Use this skill whenever the current repository or affected project contains Rust code, Cargo.toml, Cargo.lock, or Rust crates.
---

# ARGVUS Rust Code Conventions

Use this skill whenever a task involves Rust code in an ARGVUS project.

This skill is about code quality, naming, structure, idiomatic Rust, maintainability,
and consistency.

It is separate from packaging rules.

## Activation

Before editing a project, determine whether it is a Rust project.

Treat a repository as Rust-based when one or more of the following are present:

- `Cargo.toml`
- `Cargo.lock`
- `src/*.rs`
- `crates/*/Cargo.toml`
- a Rust workspace in the root `Cargo.toml`

If the task affects any Rust crate, apply this skill.

Do not rely only on the repository name.

A project may contain multiple languages.

If only a non-Rust part of a mixed repository is being modified, apply these rules
only where relevant.

## General principle

Write Rust for long-term maintenance.

Prefer code that is:

- explicit;
- readable;
- idiomatic;
- type-safe;
- testable;
- unsurprising;
- easy to debug.

Do not optimize for minimum line count.

Do not use clever abstractions when straightforward code is clearer.

## Naming

Use descriptive names.

Do not use meaningless variable names such as:

- `a`
- `b`
- `c`
- `x`
- `y`
- `z`
- `v`
- `tmp`
- `val`
- `obj`
- `data`

unless the scope and mathematical meaning make the abbreviation genuinely obvious.

Bad:

```rust
let a = config.load()?;
let b = a.theme;
let c = apply(b)?;
```

Good:

```rust
let appearance_config = config.load()?;
let selected_theme = appearance_config.theme;
let apply_result = apply_theme(selected_theme)?;
```

Bad:

```rust
for x in devices {
    if x.enabled {
        enable(x);
    }
}
```

Good:

```rust
for device in devices {
    if device.enabled {
        enable_device(device);
    }
}
```

Prefer domain-specific terminology.

Examples:

- `device`
- `profile`
- `resolution`
- `theme`
- `locale`
- `binding`
- `config_path`
- `generated_path`
- `selected_item`
- `active_theme`
- `custom_theme`
- `wallpaper_path`

Do not shorten names merely to reduce typing.

## Acceptable short names

Short names are acceptable when they are conventional and obvious in very small
scopes.

Examples:

```rust
for index in 0..items.len()
```

is preferred over:

```rust
for i in 0..items.len()
```

but `i`, `j`, `x`, or `y` may be acceptable in:

- compact mathematical code;
- coordinate calculations;
- iterators where meaning is unquestionably local;
- tests with deliberately minimal scope.

Even then, prefer descriptive names when readability benefits.

## Function names

Function names should describe behavior.

Prefer:

```rust
load_theme_registry()
normalize_hex_color()
apply_input_settings()
resolve_wallpaper_path()
generate_hyprland_bindings()
```

Avoid:

```rust
do_it()
handle()
process()
run2()
thing()
helper()
```

Generic names like `handle_event()` are acceptable only when the enclosing type or
module makes the responsibility clear.

## Boolean names

Boolean variables should read naturally.

Prefer:

```rust
is_enabled
is_active
has_override
should_reload
can_apply
needs_refresh
```

Avoid:

```rust
enabled_flag
state_bool
value
check
```

## Option and Result naming

Do not hide semantics behind vague names.

Bad:

```rust
let result = load_config();
let value = result?;
```

Good:

```rust
let config_result = load_config();
let appearance_config = config_result?;
```

When immediately using `?`, avoid unnecessary intermediate variables entirely.

Preferred:

```rust
let appearance_config = load_config()?;
```

## Avoid unnecessary clones

Do not add `.clone()` merely to satisfy the borrow checker without understanding
ownership.

Before cloning:

- inspect ownership requirements;
- prefer borrowing;
- prefer references;
- move values when ownership naturally transfers.

Clone only when it is semantically correct and inexpensive enough.

Do not contort simple code solely to eliminate every clone.

## Avoid unnecessary allocations

Prefer borrowed forms when appropriate:

- `&str` instead of `String`;
- `&Path` instead of `PathBuf`;
- slices instead of temporary `Vec`s.

Use owned types when ownership is actually required.

Do not optimize prematurely at the expense of readability.

## Paths

Use:

- `Path`
- `PathBuf`

for filesystem paths.

Do not manipulate filesystem paths through string concatenation.

Bad:

```rust
let file = home + "/.config/argvus/config.toml";
```

Good:

```rust
let config_path = home
    .join(".config")
    .join("argvus")
    .join("config.toml");
```

Prefer existing XDG/path helpers when available.

## Error handling

Do not use:

```rust
unwrap()
expect()
panic!()
```

in normal runtime paths unless an invariant is truly impossible to violate and the
reason is documented.

Prefer:

- `Result`;
- `Option`;
- `?`;
- typed errors;
- contextual error messages.

Tests may use `unwrap()`/`expect()` when failure should immediately fail the test.

## Error context

Errors should explain what operation failed.

Bad:

```rust
return Err("failed".into());
```

Good:

```rust
return Err(AppError::ConfigRead {
    path: config_path.clone(),
    source,
});
```

or use the project's existing error/context mechanism.

Do not expose only raw low-level errors to users.

## Types over strings

Do not model domain state as arbitrary strings when a constrained type is practical.

Prefer:

```rust
enum ThemeKind {
    Official,
    Custom,
}
```

over:

```rust
let theme_kind = "official";
```

Prefer enums/newtypes for:

- modes;
- categories;
- known states;
- IDs;
- validated color values;
- actions.

Do not over-engineer tiny local values.

## Stable IDs

For ARGVUS state that crosses:

- UI;
- persistence;
- generated configuration;
- runtime;

use stable semantic IDs.

Do not use translated labels as identifiers.

Do not use array position as persistent identity.

## Structs

Struct fields must use meaningful names.

Group related state coherently.

Avoid giant structs that become dumping grounds for unrelated state.

Before adding a field to a large application state object, consider whether the
state belongs to a narrower domain type.

## Enums

Prefer exhaustive enums for finite states.

Match exhaustively when practical.

Avoid catch-all `_` arms if adding a future enum variant should require conscious
handling.

Use `_` when intentionally ignoring irrelevant variants and document why when not
obvious.

## Functions

Prefer small functions with one clear responsibility.

Avoid giant functions that combine:

- parsing;
- I/O;
- state mutation;
- rendering;
- persistence;
- command execution.

Separate pure logic from side effects when doing so improves clarity and testing.

## Modules

Organize modules by domain/responsibility.

Avoid files named:

- `utils.rs`
- `helpers.rs`
- `misc.rs`

when they become collections of unrelated functions.

A small focused helper module is acceptable.

Prefer names such as:

- `theme_registry.rs`
- `keybindings.rs`
- `input.rs`
- `wallpaper.rs`
- `config.rs`

## Public API

Keep visibility narrow.

Prefer:

```rust
fn
pub(crate) fn
```

before making something fully `pub`.

Expose only what other crates/modules genuinely need.

## Constants

Use named constants for meaningful repeated values.

Bad:

```rust
if retry_count > 5
```

when `5` represents a defined policy.

Good:

```rust
const MAX_RETRY_ATTEMPTS: usize = 5;
```

Do not turn every literal into a constant.

## Magic strings

Avoid repeating protocol/interface/path/key strings throughout the code.

Centralize meaningful constants such as:

- D-Bus service names;
- interface names;
- config keys;
- environment variables;
- generated filenames.

Use existing constants/modules before adding new ones.

## Comments

Comments should explain:

- why;
- invariants;
- non-obvious constraints;
- external protocol quirks;
- safety reasoning.

Do not comment obvious syntax.

Bad:

```rust
// increment index
index += 1;
```

Good:

```rust
// Keep the previous valid generated config until the replacement
// has been fully written and validated.
```

## Code readability comments

Rust code should contain enough comments to make non-trivial behavior easy to
understand during maintenance and review.

When writing or modifying Rust code, add comments whenever they improve understanding
of:

- the purpose of a non-obvious block;
- important control flow;
- state transitions;
- ownership or lifetime decisions that are not immediately obvious;
- why a specific approach was chosen;
- assumptions and invariants;
- interactions with external systems;
- generated configuration;
- persistence behavior;
- fallback behavior;
- asynchronous/background work;
- D-Bus behavior;
- Hyprland integration;
- parsing or normalization rules;
- compatibility workarounds;
- security-sensitive decisions.

Prefer concise comments placed close to the code they explain.

Example:

```rust
// Preserve the previous generated configuration until the replacement
// has been fully written and validated. This prevents a partial write
// from breaking the next Hyprland reload.
write_generated_config_atomically(&generated_config)?;
```

For non-trivial functions, add a short explanatory comment when the function body
contains behavior that is not obvious from the function name alone.

Example:

```rust
fn apply_custom_theme(theme: &CustomTheme) -> Result<()> {
    // Apply the official base theme first so all expected defaults exist
    // before restoring the user's profile overrides.
    apply_official_theme(&theme.base_theme)?;

    apply_theme_overrides(&theme.overrides)?;

    Ok(())
}
```

For complex sequences, explain the intention of each logical phase rather than
commenting every statement.

Good:

```rust
// Resolve the persisted device ID again because device ordering may change
// between sessions.
let device = resolve_device(&settings.device_id)?;

// Apply hardware values only after the device capabilities have been refreshed.
apply_hardware_settings(&device, &settings)?;
```

Avoid comments that merely repeat the code.

Bad:

```rust
// Set enabled to true.
settings.enabled = true;

// Increment retry count.
retry_count += 1;
```

Comments should add context, intent, constraints, or reasoning.

Do not use excessive comments as a substitute for clear naming and good structure.

If code requires many comments merely to explain what each variable means, first
improve:

- variable names;
- function names;
- types;
- module boundaries;
- control flow.

Then add comments for the remaining non-obvious behavior.

When modifying existing Rust code, preserve useful comments and update comments that
became inaccurate because of the change.

Never leave stale comments that describe old behavior.

## Rustdoc for important APIs

For important reusable types and functions, use Rust documentation comments when the
contract is useful to callers.

Example:

```rust
/// Restores an imported theme profile.
///
/// The wallpaper is preserved when the profile is later removed.
/// Paths outside the current user's home directory are remapped to a
/// safe user-owned location during import.
///
/// # Errors
///
/// Returns an error when the profile manifest is invalid or when the
/// persisted appearance state cannot be restored.
pub(crate) fn restore_theme_profile(profile: &ThemeProfile) -> Result<()> {
    // ...
}
```

Use `///` especially for:

- reusable public APIs;
- core domain types;
- important configuration structures;
- non-obvious state machines;
- cross-crate interfaces;
- functions with important side effects;
- functions with meaningful error contracts.

Do not add verbose rustdoc to trivial getters/setters or obvious private helpers.

## Review checklist additions

Add these checks to the Rust review checklist:

- Does non-trivial code contain enough comments to explain intent and constraints?
- Were comments updated when behavior changed?

## Documentation comments

Use `///` for public or reusable APIs where callers need behavioral understanding.

Document:

- purpose;
- important invariants;
- errors;
- side effects;
- unusual ownership/lifetime behavior.

Do not add verbose rustdoc to trivial private functions.

## Iterators

Prefer iterator methods when they improve clarity.

Do not turn readable loops into dense chains simply to appear idiomatic.

Prefer:

```rust
let enabled_devices = devices
    .iter()
    .filter(|device| device.enabled)
    .collect::<Vec<_>>();
```

when clear.

Use an explicit loop when mutation, branching, or error handling becomes easier to
understand that way.

## Matching

Use pattern matching for domain state.

Prefer readable `match` statements over deeply nested `if let` chains when multiple
states are meaningful.

## Early returns

Use early returns to reduce nesting.

Prefer:

```rust
if !device.is_supported() {
    return Ok(());
}

apply_device_settings(device)?;
```

over unnecessary nested blocks.

## Async

Do not mark functions `async` without an asynchronous requirement.

Do not block async executors with:

- heavy filesystem traversal;
- compression;
- subprocess waiting;
- synchronous D-Bus calls;

when the project provides an appropriate async/background mechanism.

Do not introduce Tokio or another runtime merely for one operation if the project
does not already use it.

## Locks

Keep lock scope minimal.

Do not perform:

- filesystem I/O;
- process spawning;
- D-Bus calls;
- expensive computation;

while holding a mutex unless unavoidable.

Avoid nested locking patterns that can deadlock.

## Channels and background workers

Give messages meaningful types.

Prefer:

```rust
enum WorkerCommand {
    RefreshDevices,
    ApplySettings(InputSettings),
    Shutdown,
}
```

rather than loosely structured string commands.

## Configuration parsing

Validate config at boundaries.

Flow should preferably be:

raw config
→ parse
→ validate/normalize
→ typed runtime representation.

Do not repeatedly re-parse or normalize the same value throughout the application.

## Persistence

For important user state:

- write atomically;
- preserve previous valid state on failure;
- avoid partial files;
- handle missing file as appropriate;
- do not silently discard malformed data unless documented.

Use the project's existing persistence utilities when available.

## Serialization

Use explicit versioning when storing long-lived schemas that may evolve.

Avoid serializing transient runtime state.

## Generated files

Generated files are derived state.

Do not make generated output the authoritative model.

Prefer:

typed state/config
→ renderer/generator
→ generated file.

## CLI code

CLI parsing should remain separate from domain logic.

Do not bury business logic directly inside argument parsing branches.

Prefer:

CLI
→ validated request
→ reusable domain operation.

## D-Bus code

Keep:

- service names;
- object paths;
- interface names;
- property names;

centralized and explicit.

Do not use stringly typed values when the D-Bus binding can provide typed values.

Do not block UI rendering on D-Bus operations.

## TUI code

For Rust TUI projects:

- rendering should not perform I/O;
- state updates should be separate from rendering;
- focus should use stable IDs where practical;
- widgets should not own unrelated backend behavior;
- expensive operations should run outside the draw loop.

Apply the `argvus-ui` skill as well.

## Hyprland integration

For Rust code generating or controlling Hyprland:

- preserve semantic config models;
- validate before replacing generated files;
- use atomic writes;
- keep user config separate from generated output.

Apply the `argvus-hyprland` skill as well.

## Internationalization

Do not hardcode user-visible English strings in Rust components already using
`argvus-i18n`.

Apply the `argvus-i18n` skill whenever visible text changes.

## Logging

Use the logging/tracing system already adopted by the project.

Do not scatter `println!()` or `eprintln!()` throughout long-running applications
unless that is the project's intentional CLI output.

Logs should contain useful context.

Avoid noisy per-frame/per-poll logging at normal levels.

## Unsafe

Avoid `unsafe` unless necessary.

If `unsafe` is required:

- minimize scope;
- state the invariant;
- document why safe alternatives are insufficient;
- add tests where practical.

Do not introduce `unsafe` solely for micro-optimization.

## Dependencies

Before adding a crate:

1. verify the functionality does not already exist in the workspace;
2. verify the standard library is insufficient;
3. check whether another existing dependency already solves it;
4. consider maintenance and compile-time cost.

Do not add large crates for trivial helpers.

## Tests

Name tests by behavior.

Good:

```rust
fn normalizes_lowercase_hex_color()
fn preserves_wallpaper_when_custom_theme_is_deleted()
fn rejects_duplicate_keybinding()
```

Avoid:

```rust
fn test1()
fn works()
fn test_function()
```

Prefer tests for:

- domain behavior;
- edge cases;
- invalid input;
- regressions;
- persistence;
- normalization.

## Test variables

The descriptive naming rule also applies to tests.

Bad:

```rust
let a = ...
let b = ...
assert_eq!(a, b);
```

Good:

```rust
let normalized_color = ...
let expected_color = ...
assert_eq!(normalized_color, expected_color);
```

## Clippy

Do not blindly silence Clippy.

When Clippy reports an issue:

- understand it;
- fix the code when appropriate;
- use a targeted `#[allow(...)]` only when the warning is intentionally incorrect
  for that context.

Document non-obvious allowances.

Do not add crate-wide `allow` attributes merely to make CI green.

## Formatting

Use rustfmt.

Do not manually fight rustfmt formatting.

Required validation when applicable:

```sh
cargo fmt --all -- --check
```

## Compiler warnings

New code should compile without warnings.

Do not leave:

- unused variables;
- unused imports;
- dead code;
- unnecessary `mut`;
- ignored `Result`s.

If something intentionally exists for future use, reconsider whether it belongs in
the current implementation.

## Validation

For affected Rust workspaces, use relevant checks such as:

```sh
cargo fmt --all -- --check
cargo check --workspace
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --locked
```

Do not automatically run an expensive full release build after every tiny edit if
the task does not require it.

Use the repository's existing validation policy.

## Refactoring policy

Do not perform unrelated style refactors during feature work.

If nearby code violates these conventions but changing it is unnecessary:

- keep the task focused;
- improve touched code when safe;
- do not create huge unrelated diffs.

## Review checklist

Before completing a Rust task, check:

- Are variable names descriptive?
- Are functions named by behavior?
- Is ownership clear?
- Are unnecessary clones present?
- Are errors propagated/contextualized correctly?
- Are filesystem paths using `Path`/`PathBuf`?
- Are finite states typed?
- Is rendering free from I/O?
- Are generated files derived rather than authoritative?
- Are user-visible strings localized?
- Are tests named meaningfully?
- Does Clippy pass?
- Does rustfmt pass?

## Final report

For Rust changes, report:

- crates modified;
- important types/functions added;
- notable ownership/error-handling decisions;
- tests added;
- fmt/check/clippy/test results;
- remaining technical limitations.
