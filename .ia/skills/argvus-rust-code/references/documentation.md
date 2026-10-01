# Comments and documentation

Additional guidance for `argvus-rust-code`. `SKILL.md` already defines when
comments are required, what they must explain and the basic rustdoc policy. This
file adds the mechanics.

## Comment kinds

| Syntax | Use for |
| --- | --- |
| `///` | The item that follows: public API and important private items |
| `//!` | The enclosing module or crate, at the top of the file |
| `//` | Implementation notes inside bodies: the why |
| `/* */` | Rarely; prefer `//` |

Every module that is more than a few lines should start with a `//!` line that
says what it is responsible for. Crate roots (`lib.rs`, and `main.rs` for
binaries) describe the purpose and a map of the main modules.

## Rustdoc structure

Start with a one-line summary in third person, then a blank line, then details.
Skip filler such as "This function is used to...". Add sections only when they
apply:

- `# Errors` on every public function that returns `Result`, listing the
  conditions.
- `# Panics` whenever the function can panic, including indexing or `expect` on
  caller-controlled values.
- `# Safety` on every `unsafe fn` or trait: what the caller must guarantee.
- `# Examples` with runnable doctests for reusable library APIs. Doctests are
  tests and keep the docs honest. Use `?` with a hidden
  `# Ok::<(), Error>(())` line instead of `unwrap`.

```rust
/// Parses a duration such as `"1h30m"` into a [`Duration`].
///
/// Supported units are `h`, `m` and `s`. Whitespace between components is
/// ignored.
///
/// # Errors
///
/// Returns [`ParseError::UnknownUnit`] when a component uses an unsupported
/// unit and [`ParseError::Empty`] when `input` has no components.
pub fn parse_duration(input: &str) -> Result<Duration, ParseError> {
    // ...
}
```

Tips:

- Use intra-doc links: [`Type`], [`Self::method`], [`crate::module::Item`].
- Document type purpose and invariants on the type, and fields only when they
  are public or surprising.
- Document trait contracts on the trait; document only implementation-specific
  behavior on the impl.
- For library crates add `#![warn(missing_docs)]` and
  `#![warn(rustdoc::broken_intra_doc_links)]`.
- Run `cargo doc --no-deps` and read the result as a newcomer would.

## Comment hygiene

- Reference external facts with an identifier or link: `// See RFC 7230 §3.3.3`,
  `// Workaround for rust-lang/rust#12345`, or the D-Bus interface / Hyprland
  behavior that forced the code.
- Delete commented-out code. Version control remembers it.
- Keep comments adjacent to the code they describe and update them in the same
  change as the code.
- Avoid banner comments and ASCII separators; modules and functions already
  structure the file.
- Wrap comments at the same width as code (rustfmt uses 100 columns).
- In long functions that cannot be split, a few comments describing the high
  level phases are fine. If many are needed, split the function.

## TODO and FIXME

Make them searchable and actionable by naming an owner or an issue:

```rust
// TODO(owner): support IPv6 once the parser handles brackets.
// FIXME: panics on empty input; tracked in #123.
```

A TODO without a plan is clutter. For API-level migrations prefer
`#[deprecated(note = "use X instead")]` over a comment.

## Language of comments

Match the project. If the existing comments are in English, keep English; do not
mix languages within a file without a reason. ARGVUS code, rustdoc, commit
messages and documentation are written in English. Identifiers are always in
English.

## Project-level docs

- `README.md`: what it is, install, a quick usage example, link to docs, license.
- Crate docs (`//!` in `lib.rs`): purpose, a minimal example, main types and
  modules.
- `CHANGELOG.md`, when the project keeps one: Keep a Changelog categories
  (Added, Changed, Fixed, Removed) with breaking changes called out.
- Architecture notes: for non-trivial projects, a short map of modules and data
  flow. Significant choices ("why this crate", "why this layout") deserve a short
  decision note instead of long inline comments.
- User-facing changes also follow the documentation synchronization rules in
  `AGENTS.md` and `argvus-documentation`.
