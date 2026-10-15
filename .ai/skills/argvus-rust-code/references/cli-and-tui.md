# CLI and TUI applications

Additional guidance for `argvus-rust-code`. `SKILL.md` already requires CLI
parsing to stay separate from domain logic and TUI rendering to stay free of
I/O. Apply `argvus-ui` for UX and `argvus-i18n` for visible strings as well.

## CLI with clap

Use the derive API when the project already uses clap; it keeps the interface
declarative and self-documenting.

```rust
use std::path::PathBuf;

use clap::{Parser, Subcommand};

/// Manage encrypted volumes.
#[derive(Parser)]
#[command(version, about)]
pub struct Cli {
    /// Path to the config file
    #[arg(long, global = true)]
    pub config: Option<PathBuf>,

    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand)]
pub enum Command {
    /// Open a volume
    Open { name: String },
    /// List known volumes
    List,
}
```

- Keep argument definitions in `cli.rs` and convert to domain types early; the
  rest of the program should not depend on `clap`.
- Write `///` comments on every argument and subcommand: they become `--help`.
- Use `ValueEnum` for fixed choices, `value_parser` for validation and
  `conflicts_with` / `requires` for related flags.
- Make destructive actions explicit: a confirmation prompt or `--yes` /
  `--force`, and `--dry-run` where it makes sense.
- A new or changed flag is a documented user-facing change; follow the
  documentation synchronization rules.

## Output, errors and exit codes

- Results go to stdout; diagnostics, progress and errors go to stderr, so pipes
  stay clean.
- Offer `--json` for commands that scripts may consume, and keep human output
  stable and concise.
- Respect `NO_COLOR` and disable color when stdout is not a terminal
  (`std::io::IsTerminal`).
- Exit `0` on success and non-zero on failure. Use distinct codes only when
  callers benefit.
- Error messages say what failed and, when possible, how to fix it. Print the
  chain with `{err:#}` when handling the error in `main`.
- Treat `ErrorKind::BrokenPipe` (`cmd | head`) as a normal exit, not a panic.

## Configuration and paths

- Layer configuration with a clear precedence: defaults < config file <
  environment < command-line flags.
- Validate configuration once at startup and fail early with the file, key and
  reason.
- Use the XDG helper the project already has (or `directories` / `dirs`); do not
  hardcode `~/.config/...`.
- Never write secrets to logs or error messages, and avoid passing them as
  command-line arguments because they leak into process listings.
- Invoke external programs with `std::process::Command` and separate `.arg()`
  calls, never a concatenated shell string. Resolve binaries explicitly or allow
  an override, and report the command and exit status on failure.

## Logging

- Use `tracing` or `log` (whichever the project uses) instead of `println!` for
  diagnostics. `error` is for failures, `warn` for recoverable problems, `info`
  for high-level progress and `debug` / `trace` for developer detail.
- Initialize the subscriber in `main`, controlled by `RUST_LOG` or `-v`.
- A TUI owns the terminal: log to a file or an in-app panel, never to
  stdout/stderr.

## TUI with ratatui

Structure the app as an explicit state / update / view cycle:

1. State (`App`): plain data describing everything the screen needs.
2. Events: key presses, ticks, resize and results from background workers, all
   funneled into one enum.
3. Update: `fn update(&mut self, action: Action)` mutates state and never draws.
4. View: `fn draw(frame: &mut Frame, app: &App)` renders purely from state.

```rust
enum Action {
    Quit,
    Next,
    Previous,
    Select,
    Refresh,
}
```

- Separate key mapping (key to `Action`) from behavior (`Action` to state
  change). It makes keybindings configurable and logic testable without a
  terminal.
- Keep state transitions in `app.rs` and widgets under `ui/`. Split large screens
  into components with their own state, update and draw functions.
- Never block the event loop. Run slow work (disk, subprocesses, D-Bus) on a
  worker thread or async task and send the result back as an event.
- Always restore the terminal (raw mode, alternate screen, cursor, mouse
  capture) on exit, on error and on panic: install a panic hook that restores it
  before printing the panic, and wrap setup/teardown in a guard type with
  `Drop`.
- Redraw only when state changed or on a tick.
- Handle tiny terminal sizes gracefully and respond to resize events.
- Use `Layout` constraints instead of hard-coded coordinates, and keep colors and
  borders in one theme module.
- Use `unicode-width` when computing text layout manually.
- Keep the interface discoverable with a help popup or a footer listing keys.

## Testing CLIs and TUIs

- Logic first: because parsing, update and state live outside rendering, most
  behavior is covered by ordinary unit tests.
- End-to-end CLI: `assert_cmd` plus `predicates` against stdout, stderr and the
  exit status, with `tempfile` fixtures.
- Rendering: ratatui's `TestBackend` draws into an in-memory buffer that can be
  asserted on or snapshotted with `insta`.
- External tools (mounts, devices, D-Bus, networks): wrap them behind a trait so
  tests substitute a fake instead of touching real devices.
