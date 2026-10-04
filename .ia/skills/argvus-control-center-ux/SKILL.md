---
name: argvus-control-center-ux
description: UX/UI rules and roadmap for the ARGVUS Control Center (argvus/argvus-control-center, Rust/ratatui TUI, 18 crates). ALWAYS use when working on this project: screens, menus, navigation, row selection, icons, buttons (Apply/Cancel/Refresh...), confirmations, help footer, Home, the argvus-control-center-* crates, or the UX/UI standardization refactor. Also use when resuming that refactor in a new session.
---

# ARGVUS Control Center: UX/UI

Project: a *keyboard-first* TUI (mouse is complementary), Cargo workspace with 18 crates, ratatui 0.30, Rust 1.95. This skill defines how every screen must behave and drives the refactor that standardizes menus, icons and actions.

## When starting any session on this project

1. Read `docs/ux-audit.md` (inventory of buttons/options, icon table and the **Progress** section). If it does not exist, Phase 0 has not been done yet: start there (`references/phases-and-acceptance.md`).
2. Run `git log --oneline -20` and `git status` to see where the work stopped.
3. Resume from the next pending item in the Progress section. Work only on the phase/crate requested for this session.
4. When done: update **Progress** in `docs/ux-audit.md` and commit following the repository conventions (`CONTRIBUTING.md`, `cliff.toml`).

Before writing code, also read `README.md`, `DEVELOPMENT.md`, `rustfmt.toml` and `clippy.toml`. Use plan mode and show the Phase 0 plan before migrating any screen.

## Golden rule: functional preservation

This is a refactor of **presentation and navigation**. Every existing feature, option and action stays available, with the same system effect. Removing a button such as `[ Apply ]` means moving the option to an equivalent **menu row** (`Apply`), never deleting the option and never changing **when a change takes effect** (immediate stays immediate; draft stays draft). The same goes for keyboard shortcuts (`r` refresh, `/` search...), direct CLI routes and i18n strings (en and pt-br). When in doubt between removing and keeping an option, keep it and ask.

## Design rules (summary; full detail in `references/design-rules.md`)

- **One vertical list per screen.** No button bar, no `[ Apply ]`/`[ Cancel ]`/`[ OK ]` labels, no `Tab` to "go to the buttons". Enter/`→` activates, Esc/`←` goes back, Space toggles, `↑↓jk PgUp/PgDn Home/End` navigate. `Tab` only switches tabs/panes where that already exists.
- **Every button becomes a menu row (Action type)**, with a translated label, icon and shortcut. On `appearance` pages that use a draft, `Apply` is the last row of the list, dimmed and skipped while there are no pending changes; `Esc` with a pending draft asks for confirmation before discarding.
- **Row types** (shared enum, e.g. `RowKind`): Info (not selectable), Action, Submenu, Toggle, Choice, Value, Destructive.
- **Info rows never receive focus**, by keyboard or mouse. The cursor skips them; the initial selection lands on the first selectable row; a page with no selectable row becomes scroll-only. Temporarily invalid rows are shown disabled and skipped.
- **Semantic, unique icons.** The icon belongs to the item (never passed by hand in `format!`, never chosen by index). No `INFO`/`STORAGE`/`SUCCESS` as wildcards. Siblings do not repeat an icon without reason. Info rows get no decorative icon. The catalog lives in `argvus-tui::icons` (`nf-md-*` glyphs, one cell wide).
- **A single confirmation component** for destructive/privileged actions (Confirm/Cancel, Enter/Esc, `y`/`n`).
- **Context-derived help footer** (row type + page), instead of one i18n key per screen.
- Colors only through `argvus-theme` (semantic). Must work with icons on and off, at 80x24, with and without mouse.

## Where to make changes

`argvus-tui` (chrome, `page::{Selection, list, readonly, shell, status}`, `icons`) is **not in this repository**. Find out how it is resolved (path, git or sibling checkout) and put the row model, the single list, the confirmation and the footer there. If you cannot access its source, **stop and tell the user** instead of duplicating those pieces in every crate.

Migration order: `appearance` → `settings` → `displays` → `boot` → `packages` → `network` → `services` → `audio` → `bluetooth` → `power` → `storage` → `hardware` → `diagnostics` → `session` → `about` → Home.

## Reference map (read only what the phase needs)

- `references/design-rules.md`: complete rules (navigation model, Apply/Cancel, confirmation, Info rows, icons, footer).
- `references/diagnosis.md`: problems found in the code, with files and symbols. It is a snapshot from Phase 0; **confirm in the code before acting** and do not treat it as a permanent rule.
- `references/phases-and-acceptance.md`: phases 0 to 4, anti-regression inventory, acceptance criteria, checks (`fmt`, `clippy -D warnings`, `test`, `build --release`) and report format.

## How to report

At the end of each phase: what changed, what was left out and why, and decisions that need confirmation. Make no changes outside the UX/UI scope. If any rule turns out to be infeasible, explain it with evidence (file and line) and propose the closest alternative instead of working around it silently.
