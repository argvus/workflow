# Phases, acceptance criteria and report

Work in phases, with small commits per phase, and update **Progress** in `docs/ux-audit.md` at the end of each one. One phase (or one crate of Phase 3) per session, to keep the context small.

## Phases

0. **Audit** (no behavior changes). Produce `docs/ux-audit.md` with: (0) the button/option inventory (`crate > screen > current button/option > action > new equivalent row > shortcut`), (1) the icon table, (2) per crate, which navigation/confirmation/button idioms it uses, (3) the list of Info rows that are selectable today, (4) the proposal for `RowKind` and the shared API, (5) a **Progress** section (phases and crates, with status) and (6) **Decision points**. **Stop and show the plan** before going further.
1. **Foundation** in `argvus-tui`: `RowKind`, a single list whose selection skips Info rows, the confirmation component, the contextual footer, the icon as part of the item. Unit tests for the cursor (skips Info, empty list, Info-only page, Home/End, PgUp/PgDn, disabled rows).
2. **Migrate `appearance`** as the reference: remove the `Button`/button bar and turn `Apply` (and `Cancel`, when present) into Action rows at the end of the list, keeping the draft model; fix icons (Taskbar and the others); Info rows not selectable.
3. **Remaining crates**, one per commit, in the order given in `SKILL.md`. Remove `ActionButton`, `on_buttons`, `button_selected`, `button_from` and the `[ ... ]` rows in `settings`. Check the inventory for each crate.
4. **Cleanup**: orphaned i18n keys (en and pt-br), dead code (`#[allow(dead_code)]` tied to the old Transparency/Blur pages, if confirmed), the README's "Keyboard controls" section and a CHANGELOG entry.

## Acceptance criteria

- No screen shows a button bar or `[ Apply ]`, `[ Cancel ]`, `[ OK ]` labels. No crate keeps `on_buttons` state.
- **Every action that used to be a button is still reachable as a menu row** (including `Apply` on the appearance pages), with the `docs/ux-audit.md` inventory 100% marked as migrated. No existing option or shortcut was lost.
- When each change takes effect (immediate or via `Apply`) is the same as before the refactor.
- All screens follow the same key vocabulary and markers.
- No Info row receives focus, by keyboard or mouse.
- Every menu item has a coherent icon, unique among siblings; the audit table is resolved (no HDD icon on Taskbar).
- A single confirmation component, used for every destructive action.
- Works with icons on and off, at 80x24, with and without mouse.
- Rendering tests (`TestBackend`) updated, including the one that currently looks for `"[ Reset Defaults ]"`. Tests cover that action rows (`Apply`, `Cancel`, `Refresh`...) exist, are enabled/disabled in the right states and trigger the same action as before.
- These pass without warnings: `cargo fmt --check`, `cargo clippy --workspace --all-targets --all-features -- -D warnings`, `cargo test --workspace`, `cargo build --release --workspace` (or `make check`), and cspell if the project requires it.
- Functional behavior preserved: no system operation changes; only how it is triggered.

## Report at the end of each phase

A few lines: what changed, what was left out and why, decisions that need confirmation. No changes outside the UX/UI scope.
