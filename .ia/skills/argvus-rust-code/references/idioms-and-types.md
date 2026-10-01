# Idioms, types, errors, ownership and concurrency

Additional guidance for `argvus-rust-code`. Read it when writing or reviewing
functions, types, error handling, ownership, iterators, traits, concurrency,
`unsafe` or performance-sensitive code.

The rules in `SKILL.md` and the conventions already present in the project win
when they conflict with this file.

## Contents

- Standard naming conventions
- Types and data modeling
- Ownership and borrowing
- Error handling
- Functions
- Pattern matching and control flow
- Iterators and collections
- Strings and paths
- Traits and generics
- Concurrency and async
- Unsafe
- Performance

## Standard naming conventions

`SKILL.md` covers descriptive names. These are the Rust API Guidelines (RFC 430)
that readers rely on:

| Item | Convention | Example |
| --- | --- | --- |
| Functions, methods, variables, modules | `snake_case` | `parse_config` |
| Types, traits, enum variants | `UpperCamelCase` | `ConfigError` |
| Constants, statics | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_ATTEMPTS` |
| Lifetimes | short lowercase | `'a`, `'src` |

Method prefixes carry a cost contract:

- `new()` is the primary constructor, `with_x()` a constructor with one custom
  option, `from_x()` / `impl From<X>` a conversion.
- `as_x()` is a cheap borrowed view, `to_x()` an expensive or copying
  conversion, `into_x()` a consuming conversion.
- Getters drop the `get_` prefix: `name()`, not `get_name()`. Keep `get` /
  `get_mut` for lookups by key or index.
- Iterator-producing methods are `iter()`, `iter_mut()` and `into_iter()`.
- Acronyms are words: `HttpClient`, `DbusService`, not `HTTPClient`.
- Put units in the name or the type: `timeout_secs` or `Duration`, never a
  comment.

## Types and data modeling

Make invalid states unrepresentable.

Newtypes give domain meaning and stop values from being mixed:

```rust
pub struct DeviceId(String);
pub struct ProfileId(String);

fn apply_profile(device: &DeviceId, profile: &ProfileId) { /* ... */ }
```

Enums replace boolean parameters. `connect(host, true)` says nothing at the
call site; `connect(host, Tls::Enabled)` does.

Put data inside the variant that owns it instead of keeping optional fields that
are only valid in some states:

```rust
enum SessionState {
    Idle,
    Authenticating { attempt: u32 },
    Active { session: Session },
}
```

More rules:

- Use `Option<T>` instead of sentinels such as `-1`, `""` or `0`.
- Use a struct with named fields when a function needs more than about four
  positional arguments. Use a builder, or `Default` with struct update syntax
  (`Config { retries: 5, ..Config::default() }`), for many optional fields.
- Derive `Debug` on everything. Add `Clone`, `PartialEq`, `Eq`, `Hash` and
  `Default` when they are meaningful. Use `Copy` only for small plain data.
- Add `#[non_exhaustive]` to public enums and structs that are expected to grow,
  so adding a variant is not a breaking change.
- Keep fields private when invariants exist and expose a validating constructor
  (parse, do not validate later).
- Implement `FromStr`, `Display`, `From` and `TryFrom` for domain types instead
  of ad-hoc `parse_x` / `to_string_x` helpers.

## Ownership and borrowing

`SKILL.md` covers `&str`, `&Path` and avoiding blind clones. Also:

- Accept `&[T]` instead of `&Vec<T>` and `&str` instead of `&String`. Use
  `impl AsRef<Path>` or `impl Into<String>` only when the caller ergonomics are
  a real gain.
- Return owned values unless returning a borrow is the point
  (`fn name(&self) -> &str`).
- If lifetime parameters start infecting every signature around a struct, own
  the data (`String`, `Vec<T>`, `Arc<str>`) instead.
- `Cow<'a, str>` fits functions that usually return their input unchanged and
  only sometimes allocate.
- `Rc<RefCell<T>>` and `Arc<Mutex<T>>` are for genuinely shared mutable state.
  They are not a workaround for unclear ownership; restructure or use message
  passing first.
- Prefer passing `&mut T` down the call stack over storing it in a struct.
- Never add `'static` bounds only to silence the compiler.

## Error handling

`SKILL.md` forbids `unwrap` / `expect` / `panic!` in runtime paths and asks for
contextual errors. Also:

- Core and library crates define typed errors with `thiserror`. Application
  binaries may use `anyhow` (or `color-eyre`) and add context with
  `.with_context(...)`. Follow the error crate the project already uses.
- Use `?` to propagate. Avoid a manual `match` that only re-wraps the error.
- Error messages are lowercase, carry no trailing punctuation and describe what
  failed ("could not read config at /path"), not what to do. Text shown to the
  user still goes through `argvus-i18n` where the component uses it; keep the
  technical error chain for logs and `--verbose`.
- Never silently discard a `Result` with `let _ = ...`. Propagate or log it, or
  comment why ignoring it is safe (for example a best-effort cleanup).
- Avoid `Box<dyn Error>` in public APIs of library crates; it blocks matching
  on error kinds.
- Document remaining panics under `# Panics`, and use
  `expect("invariant: <why this cannot fail>")` only for real invariants.
- Mark functions whose result must not be ignored with `#[must_use]`.
- `main` may return `Result<()>`; keep it thin.

```rust
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("could not read config at {path}")]
    Read {
        path: std::path::PathBuf,
        #[source]
        source: std::io::Error,
    },
    #[error("invalid value for `{key}`: {reason}")]
    Invalid { key: &'static str, reason: String },
}
```

## Functions

`SKILL.md` covers small functions and early returns. Also:

- If you need "and" to describe a function, split it.
- Keep side effects at the edges and logic in pure functions that are easy to
  test.
- A function that needs a screen of comments to be understood usually needs to
  be split or renamed instead.
- Use `let ... else` for early exits:

```rust
let Some(profile) = selected_profile else {
    return Ok(Output::empty());
};
```

## Pattern matching and control flow

- Use `if let` for one pattern, `let ... else` for early exit and `matches!` for
  boolean checks.
- Match on tuples instead of nested `if` chains when combining conditions.
- Use labeled breaks in nested loops instead of flag variables.
- Use a catch-all `_ =>` deliberately for foreign or `#[non_exhaustive]` types,
  not for your own enums.

## Iterators and collections

- A chain longer than about five adapters usually deserves intermediate
  variables or a named helper.
- Collect fallibly: `items.iter().map(parse).collect::<Result<Vec<_>, _>>()?`.
- Pre-size with `Vec::with_capacity(n)` when the size is known.
- Do not index in loops when `iter().enumerate()`, `windows` or `chunks` express
  the intent; this also removes a panic path.
- Choose collections on purpose: `Vec` by default, `HashMap` for lookup,
  `BTreeMap` / `BTreeSet` when ordering or deterministic output matters (for
  example generated configuration), `VecDeque` for queues.
- Use `.copied()` / `.cloned()` instead of `.map(|item| *item)`.

## Strings and paths

- Build strings with `format!`, `push_str` or `write!`; avoid repeated `+` in
  loops.
- Use `.display()` to print a `Path`; use `to_string_lossy()` only when lossy
  output is acceptable.
- Byte-indexing a `str` can panic on non-ASCII boundaries. Use `char`-aware
  methods for user text.

## Traits and generics

- Start concrete. Introduce a trait when there are two real implementations or
  a genuine test seam (for example a fake for D-Bus or process execution).
- Use `impl Trait` in argument position for simple generics and `dyn Trait` for
  heterogeneous collections or to limit compile time.
- Put long bounds in `where` clauses.
- Prefer composition over deep trait hierarchies; do not simulate inheritance.

## Concurrency and async

`SKILL.md` covers lock scope, typed channel messages and not blocking
executors. Also:

- Never hold a `std::sync::Mutex` guard across an `.await`. Scope the guard in
  a block, or use an async-aware mutex when you must.
- Run blocking or CPU-heavy work with `spawn_blocking` (or a worker thread), not
  on an executor thread.
- Use one async runtime per project and keep runtime-specific code at the edges.
- Assume any `.await` can be dropped; keep cancellation safe.
- Use `std::thread::scope` to borrow data in short-lived threads.

## Unsafe

`SKILL.md` covers minimizing `unsafe`. Also:

- Every `unsafe` block gets a `// SAFETY:` comment stating why its
  preconditions hold. Every `unsafe fn` documents a `# Safety` section.
- Wrap `unsafe` in a safe API that upholds the invariants.
- Add `#![forbid(unsafe_code)]` (or `unsafe_code = "forbid"` in `[lints.rust]`)
  to crates that do not need it.

## Performance

- Measure first (`cargo bench` with criterion, `cargo flamegraph`, `perf`). Do
  not optimize on a hunch, and never trade readability for speculative speed.
- The usual wins are algorithmic, or removing allocations in hot loops (reuse
  buffers, `with_capacity`, no `to_string()` in inner loops).
- Use slices instead of copies and `Arc<str>` for cheap shared strings.
- Do not change `[profile.release]` (LTO, `codegen-units`, `panic = "abort"`,
  `strip`) without reviewing the effect on packaging and build caching; apply
  `argvus-rust-packaging` first.
- Skip premature `#[inline]`; the compiler handles inlining within a crate.
