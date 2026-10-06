---
name: argvus-control-center-ux
description: UX/UI rules and roadmap for the ARGVUS Control Center (argvus/argvus-control-center, Rust/ratatui TUI, 18 crates). ALWAYS use when working on this project: screens, menus, navigation, row selection, icons, buttons (Apply/Save/Cancel/Refresh...), confirmations, sections, danger zone, help footer, Home, the argvus-control-center-* crates, or the UX/UI standardization refactor. Also use when resuming that refactor in a new session.
---

# ARGVUS Control Center: UX/UI

Project: a *keyboard-first* TUI (mouse is complementary), Cargo workspace with 18 crates, ratatui 0.30, Rust 1.95. This skill defines how every screen must behave and drives the refactor that standardizes menus, icons and actions.

## When starting any session on this project

1. Read `docs/ux-audit.md` (inventory of buttons/options, icon table, decisions in section 6.1 and the **Progress** section). If it does not exist, Phase 0 has not been done yet: start there (`references/phases-and-acceptance.md`).
2. Run `git log --oneline -20` and `git status` to see where the work stopped.
3. Resume from the next pending item in the Progress section. Work only on the phase/crate requested for this session.
4. When done: update **Progress** in `docs/ux-audit.md` and commit following the repository conventions (`CONTRIBUTING.md`, `cliff.toml`).

Before writing code, also read `README.md`, `DEVELOPMENT.md`, `rustfmt.toml` and `clippy.toml`. Show the plan and wait for approval before migrating any screen. The `appearance` migration (Phase 2) is the reference implementation for the shared components.

## Golden rule: functional preservation

This is a refactor of **presentation and navigation**. Every existing feature, option and action stays available, with the same system effect. Removing a button such as `[ Apply ]` means moving the option to an equivalent **menu row** (`Apply`), never deleting the option and never changing **when a change takes effect** (immediate stays immediate; draft stays draft). The same goes for keyboard shortcuts (`r` refresh, `/` search, Space...), direct CLI routes and i18n strings (en and pt-br). When in doubt between removing and keeping an option, keep it and ask.

## Design rules (summary; full detail in `references/design-rules.md`)

- **One vertical list per screen.** No button bar, no `[ Apply ]`/`[ Cancel ]`/`[ OK ]` labels, no `Tab` to "go to the buttons". Enter/`→` activates, Esc/`←` goes back, Space toggles, `↑↓jk PgUp/PgDn Home/End` navigate. `Tab` only switches tabs/panes where that already exists. On Value rows with a step, `←/→` adjust and only Esc goes back.
- **Every button becomes a menu row**, with a translated label, icon and shortcut.
- **Sections:** pages with more than one topic are split into titled sections (accent color, no `--`). Order: editable fields, their actions, other sections, **Danger zone last**.
- **Draft pages:** the Apply/Save row is the **last row of the block it commits** (right after the editable fields), dimmed and skipped while there are no pending changes. `Esc` with a pending draft asks for confirmation. Reloads never replace a dirty draft.
- **Paired actions** (Lock/Unlock, Enable/Disable) may become one status row whose Enter switches state, when the backend knows the current state; both actions stay reachable.
- **Destructive actions** go in a **Danger zone** section at the end, in the danger style, always through the single confirmation component (`argvus_tui::confirm`): two vertical rows `Confirm`/`Cancel`, focus always starts on **Cancel**; Enter runs the focused row, `y` confirms, `n`/Esc cancel, `↑↓`/`jk`/Tab move the focus.
- **Row types** (`argvus_tui::menu::RowKind`): Info and Separator (not selectable), Action, Submenu, Toggle (`[x]`/`[ ]`), Choice (`●`), Value, Destructive.
- **Info rows never receive focus**, by keyboard or mouse. Temporarily invalid rows are shown disabled and skipped.
- **Semantic, unique icons.** The icon belongs to the item (never passed by hand, never chosen by index). No `INFO`/`STORAGE`/`SUCCESS` as wildcards. Info rows and homogeneous lists get no decorative icon. Catalog in `argvus-tui::icons` (`nf-md-*`, one cell).
- **Context-derived help footer** (`argvus_tui::hints`), instead of one i18n key per screen.
- Colors only through `argvus-theme` (semantic). Must work with icons on and off, at 80x24, with and without mouse.

## Where to make changes

Shared components live in `argvus-tui` (sibling checkout, consumed by path): `menu` (`RowKind`, `Row`, `MenuState`, `draw_menu`, `draft_actions`), `confirm`, `hints`, `icons`. Crates consume them; do not duplicate them per crate. New translation keys go to `argvus-i18n` (en-US and pt-BR). If a shared piece is missing, add it to `argvus-tui` in its own commit.

Migration order: `appearance` (done) → `settings` → `displays` → `boot` → `packages` → `network` → `services` → `audio` → `bluetooth` → `power` → `storage` → `hardware` → `diagnostics` → `session` → `about` → Home.

## Reference map (read only what the phase needs)

- `references/design-rules.md`: complete rules (navigation, sections, Apply/Save, paired actions, danger zone, confirmation, Info rows, icons, footer).
- `references/diagnosis.md`: problems found in the code, with files and symbols. It is a snapshot from Phase 0; **confirm in the code before acting** and do not treat it as a permanent rule.
- `references/phases-and-acceptance.md`: phases 0 to 4, anti-regression inventory, acceptance criteria, checks (`fmt`, `clippy -D warnings`, `test`, `build --release`) and report format.

## How to report

At the end of each phase or crate: what changed, what was left out and why, behaviors that changed, and decisions that need confirmation. Make no changes outside the UX/UI scope. If any rule turns out to be infeasible, explain it with evidence (file and line) and propose the closest alternative instead of working around it silently.
