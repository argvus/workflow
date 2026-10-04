# Initial diagnosis (Phase 0 snapshot, 2026-10-04)

These points were found by reading the repository. **Confirm each one in the code before acting** (the code changes) and look for others of the same kind. When an item is resolved, mark it here as done. This file is not a permanent rule.

## a) Every crate reinvents navigation
- `argvus-control-center-{boot,packages,network,bluetooth,audio,hardware,services}` each have their own `ActionButton` enum and the `on_buttons` / `button_selected` / `button_from` state trio. `Tab` switches between the list and a button bar.
- `argvus-control-center-appearance` uses `Button::new(..., ButtonKind::Primary)` with the text `Apply` (`fn buttons()` in `src/ui.rs`; pages Taskbar, TaskbarIcons, TaskbarDate, TaskbarTime, WidgetTelemetry, ControlPanel, SurfaceSection and effects).
- `argvus-control-center-settings` has its own rendering (`src/ui/list.rs`, `popup.rs`) and uses *text rows* as buttons: `format!("[ {} ]", ...)` in `src/app.rs` (Change shortcut, Disable, Restore default, Apply/Try again, Cancel). There is a test that looks for `"[ Reset Defaults ]"` (`src/ui/mod.rs`).
- Confirmations done in 3 ways: a hand-drawn popup with `>  Delete` / `>  Cancel` (appearance, theme), `ConfirmationState` (boot), `confirm_forget` (network).
- State markers vary: `●` (current), `>` (selected), `[x]`/`[ ]` (checkbox), a ` · current` suffix, the value after ` · `, ` > 50%` on value rows.
- The footer uses dozens of near-identical i18n keys (`control_center.navigate_tab_actions_move_enter_activate_r_refresh_esc_back_help` and variants), written by hand per screen.

## b) Informational-only rows are selectable
In `appearance/src/ui.rs` the page rows are `Vec<String>`, with no type information. Mixed pages (information + action) let the cursor stop on any row. The `settings` crate already has `row_selectable(index)`; the others do not. The `readonly()` helper in `argvus_tui::page` is only used by fully read-only screens.

## c) Wrong or generic icons
`icon_label(icon, label)` receives `argvus_tui::icons` constants chosen by hand on each row. In `appearance/src/ui.rs` (`home_rows`):
- `Taskbar`, `Spaces/Borders Position`, `Terminal`, `Launcher` and `Appearance Mode` use `icons::STORAGE` (an HDD icon).
- `Widget Telemetry` and `Control Panel` use the same `icons::WIDGET`.
- `Effects` uses `icons::SUCCESS` (an "ok" icon).
- Dozens of rows use `icons::INFO` as a wildcard, including action options (`Top`, `Bottom`, `Left`, `Right`, `Inner gap`, `Outer gap *`, `Rounded`, `Thickness`; pages `TaskbarPosition`, `TaskbarSpaces`, `WindowSpaces`, `GeneralBorders`, `EdgeThickness`).
- On the Home (`argvus-control-center/src/ui.rs`), `home_icon_for_item(action: usize)` picks the icon **by numeric index**; it breaks silently when the order changes.
- The catalog lives in `argvus-tui::icons` (Material Design Icons via Nerd Fonts, `nf-md-*`, one cell wide). The README requires the catalog and icon/label spacing to stay there; the crates in this repository only consume them.

## d) Menu items come from `Vec<String>` + indices
The page decides what Enter does with `match self.selected { 0 => ..., 1 => ... }`. Text, icon, action and selectability live in different places and drift out of sync.

## Reference size
About 60k lines of Rust. Largest UI files: `appearance/src/ui.rs` (~3350), `settings/src/app.rs` (~3900), `displays/src/ui.rs` (~2800), `packages/src/ui.rs` (~2570), `boot/src/ui.rs`, `network/src/ui.rs`, `services/src/ui.rs`. Do not do everything in one session: one crate at a time.
