# Design rules (complete)

Decisions already made: implement them, do not reopen them. If one proves infeasible, explain with evidence and propose the closest alternative.

## 1. Navigation model: a single vertical list, no buttons

- Each screen is **one vertical list**. There is no button bar, no `[ Apply ]`, `[ Cancel ]`, `[ OK ]` style labels, and no `Tab` to "go to the buttons". **Actions still exist, as menu rows** (section 2).
- **Enter** (or `→`) activates the row. **Esc** (or `←`) goes back or cancels. **Space** toggles. `↑/↓/j/k`, `PgUp/PgDn`, `Home/End` navigate. `/` searches where it already exists. `?` is help and `q` quits, as today.
- Exceptions already decided:
  - On **Value rows with a step**, `←/→` adjust the value (D3) and only **Esc** goes back; the footer shows both.
  - Where a page already used **Space** to activate rows (for example `appearance`, D16), keep that behavior on that page instead of restricting Space to toggles. Never remove an existing shortcut.
- `Tab`/`Shift+Tab` remain **only** for switching tabs or panes where that already exists (for example About). Never to jump to buttons.
- Row types (shared enum `RowKind` in `argvus_tui::menu`):
  - **Info**: label + value. **Not selectable.**
  - **Action**: Enter runs it (Connect, Refresh, Regenerate, Restore default...).
  - **Submenu**: Enter opens another page. Navigation indicator on the right (`›`).
  - **Toggle**: Enter/Space flips it. It takes effect immediately or goes into the draft, **exactly as it does today** on that page. Visual: `[x]`/`[ ]` in the marker column, everywhere (D1).
  - **Choice**: mutually exclusive options. The current item carries `●`. Enter selects; when it takes effect follows the page's current behavior.
  - **Value** (number/text): Enter opens inline editing or a popup; Enter confirms, Esc cancels the edit. `←/→` adjust numeric and percentage steps.
  - **Destructive**: action with mandatory confirmation (section 2), drawn with the theme's danger style.
  - **Separator**: section title or divider. Not selectable.
- **Why no buttons:** "select a row + Enter" is what the app already does on most screens and what the README promises. It removes the `on_buttons`/`button_from` state, avoids the "is focus on the buttons or the list?" question, works the same with the mouse (click = Enter on the row) and reduces the keys to remember. The user loses no action: it only changes where the action is triggered from.

### 1.1 Sections and visual layout

- A page with more than one topic is split into **titled sections** (for example `Account`, `Password`, `Avatar`, `Danger zone`). The title is a Separator row in the theme's accent color, translated, with no `--` or other ASCII decoration. Rows under it are indented.
- Order inside a page: editable fields and options first, then the actions that relate to them, and the **Danger zone** always last.
- Long values are truncated with `…` on the right; the full value is visible when the row is opened (Submenu or Value editor).

## 2. Every button becomes a menu row (no option is removed)

**Removing the *button* does not remove the *option*.** Every current button (`Apply`, `Save changes`, `Cancel`, `Refresh`, `Connect`, `Disconnect`, `Forget`, `Install`, `Remove`, `Update`, `Upgrade`, `Regenerate`, `Restore default`, `Reset Defaults`, `Try again`, etc.) stays available as a **row** in the list itself, with a translated label, icon, shortcut and the same action as before.

### 2.1 Draft pages (Apply / Save)

- **Keep the draft model where it exists today**, in any crate (for example the `appearance` pages that edit `surface_draft()`: Taskbar, TaskbarIcons, TaskbarDate, TaskbarTime, WidgetTelemetry, ControlPanel, SurfaceSection, effects; or `settings > Users` with `Save changes`). Changes remain a draft and are **only applied** when the user activates the **Apply/Save row** (`argvus_tui::menu::draft_actions`). Do **not** switch these pages to immediate apply.
- **Position:** the Apply/Save row is the **last row of the block it commits**, right after the editable fields, preceded by a separator. It is not necessarily the last row of the page: when the page also has other sections (password, avatar, danger zone...), those come after it. If the whole page is the draft block, Apply is the last row of the page.
- Apply/Save is disabled and dimmed (skipped by the cursor) while there are no pending changes, and shows a "changed" indicator when there are.
- Where `Cancel`/`Discard` existed, keep a **`Cancel`** row (discards the draft and goes back). `Esc` is equivalent to it. With a pending draft, `Esc` asks for confirmation before discarding (focus on Cancel), instead of silently losing changes. Moving between subpages that share the same draft does not ask.
- A reload (`r` or automatic refresh) never replaces a draft that has pending changes (D15).

### 2.2 Immediate actions

- Where the action is already immediate today (toggles, theme/position/accent choice, `Connect`, `Refresh`...), keep it immediate. Do **not** turn an immediate action into a draft, or a draft into an immediate action.
- Slow operations stay as jobs (`JobManager`), with progress and result in the status bar, without blocking the render loop. Preserve existing validation (`validate_content` and similar) and show the error on the row.

### 2.3 Paired actions with opposite states

- Actions that are opposites of one state (`Lock`/`Unlock password`, `Enable`/`Disable`, `Connect`/`Disconnect`) may become **one status row** (for example `Password status · Active ›`) whose Enter switches to the other state, with confirmation when the action is privileged. Both actions must stay reachable, and the inventory records the merge.
- Only merge when the backend knows the current state. If it does not, keep one row per action and report it.

### 2.4 Destructive actions and the Danger zone

- **Destructive, privileged or hard-to-revert actions** (deleting a user or theme, forgetting a network, regenerating GRUB, installing/removing packages, touching disks, shutting down) go in a **`Danger zone`** section at the end of the page when the page has other content, drawn with the theme's danger style.
- **One single** centralized confirmation component. Layout: title, description, two vertical rows (`Confirm` / `Cancel`). The focus **always starts on `Cancel`** (as every existing `ConfirmationState::default()` did), also for dangerous actions. **Enter runs the focused row** (so Enter right after opening cancels), `y` confirms, `n` and Esc cancel, and `↑/↓`, `j/k`, `←/→` and Tab move the focus between the two rows. Implemented as `argvus_tui::confirm::{ConfirmState, ConfirmOutcome, ConfirmDialog, draw_confirm}`, with the footer from `argvus_tui::hints::confirm_hints`. Remove the old per-crate mechanisms, but keep every confirmation that already exists.

### 2.5 Item-dependent actions

- For buttons that depend on the selected item (`Connect`/`Forget` on a Wi-Fi network, `Install`/`Remove` on a package, actions on a user), show the actions as rows on the item's detail page (or in an actions submenu opened with Enter), keeping one-key shortcuts where they already exist.

### 2.6 Suggested page layout

```
<Section title>
  editable fields / options
  ─────────────
  Apply / Save            (draft pages only; dimmed without changes)
<Section title>
  related actions (Submenu / Action / status rows)
Danger zone
  destructive actions     (danger style, confirmation)
```

### Mandatory inventory (anti-regression)

Before removing any button, generate in `docs/ux-audit.md` a table `crate > screen > current button/option > action performed > new equivalent menu row > shortcut`. At the end of each phase, check the table and mark every item as migrated. **No item may be left without an equivalent.** An option that seems pointless to keep goes into "Decision points", and you ask.

## 3. Informational rows never receive focus

- The cursor **skips** Info and Separator rows on `↑/↓/j/k/PgUp/PgDn/Home/End`. The initial selection lands on the first selectable row. Mouse clicks on Info rows are ignored.
- A page with no selectable row enters scroll mode (the current `readonly()` behavior), with no cursor.
- Visual: Info rows use the theme's "dim" color (semantic colors from `argvus-theme`, nothing hardcoded), label on the left and value right-aligned, **without** the `>` marker and **without** an action icon.
- A temporarily invalid row (for example "Rounding" while "Rounded" is off): show it disabled and skip it, instead of leaving it selectable and without effect.

## 4. Semantic, unique icons

- Single source of truth: the icon **belongs to the item** (a field on `Row` or an `icon_for(Item)` function), never passed by hand in each `format!`. Eliminate `home_icon_for_item(usize)` and any index-based mapping.
- Every **navigable or actionable** item has its own icon that matches its meaning (Taskbar → taskbar/window, Theme → palette, Wallpaper → image, Effects → wand/sparkle, Terminal → terminal, Launcher → rocket/app grid, Widget Telemetry → chart/gauge, Control Panel → sliders/panel, Position top/bottom/left/right → arrows or alignment, Gaps/Thickness/Rounded → spacing/border).
- Two sibling items do **not** share the same icon, unless their meaning is identical.
- **Info** rows and items of homogeneous lists (families, files, formats...) get no decorative icon (D9). `INFO`/`STORAGE`/`SUCCESS` stop being wildcards: `INFO` only for actual information, `STORAGE` only for storage, `SUCCESS` only for a success state.
- State icons (`●`, `[x]`) live in the marker column, not mixed with the item icon.
- **Full audit** in `docs/ux-audit.md`: `screen > item > current icon > proposed icon`, for all 18 crates and the Home.
- New glyphs go into the `argvus-tui::icons` catalog, one cell wide (Symbols Nerd Font Mono) and honoring `AppConfig::icon()` (returns empty with icons off; rows must stay aligned in both cases). Confirm the glyph exists in `nf-md-*` before using it.

## 5. Contextual help footer

Generate the footer from the selected row's type and the page (`argvus_tui::hints`), for example `↑↓ navigate · Enter open/activate · Space toggle · ←/→ adjust · Esc back · ? help`, instead of an i18n key written per screen (D12). Show only the keys that apply to the current row; page shortcuts go in `extra`. Remove help i18n keys that become unused, in both **en** and **pt-br** (Phase 4).
