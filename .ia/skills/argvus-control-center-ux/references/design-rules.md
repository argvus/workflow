# Design rules (complete)

Decisions already made: implement them, do not reopen them. If one proves infeasible, explain with evidence and propose the closest alternative.

## 1. Navigation model: a single vertical list, no buttons

- Each screen is **one vertical list**. There is no button bar, no `[ Apply ]`, `[ Cancel ]`, `[ OK ]` style labels, and no `Tab` to "go to the buttons". **Actions still exist, as menu rows** (section 2).
- **Enter** (or `→`) activates the row. **Esc** (or `←`) goes back or cancels. **Space** toggles. `↑/↓/j/k`, `PgUp/PgDn`, `Home/End` navigate. `/` searches where it already exists. `?` is help and `q` quits, as today.
- `Tab`/`Shift+Tab` remain **only** for switching tabs or panes where that already exists (for example About). Never to jump to buttons.
- Row types (shared enum, for example `RowKind`):
  - **Info**: label + value. **Not selectable.**
  - **Action**: Enter runs it (Connect, Refresh, Regenerate, Restore default...).
  - **Submenu**: Enter opens another page. Navigation indicator on the right (for example `›`).
  - **Toggle**: Enter/Space flips it. It takes effect immediately or goes into the draft, **exactly as it does today** on that page. One consistent visual (`[x]`/`[ ]` or a switch glyph; pick one and use it across the app).
  - **Choice**: mutually exclusive options. The current item carries `●`. Enter selects; when it takes effect follows the page's current behavior.
  - **Value** (number/text): Enter opens inline editing or a popup; Enter confirms, Esc cancels the edit. `←/→` adjust numeric and percentage steps.
  - **Destructive**: action with mandatory confirmation (section 2).
- **Why no buttons:** "select a row + Enter" is what the app already does on most screens and what the README promises. It removes the `on_buttons`/`button_from` state, avoids the "is focus on the buttons or the list?" question, works the same with the mouse (click = Enter on the row) and reduces the keys to remember. The user loses no action: it only changes where the action is triggered from.

## 2. Every button becomes a menu row (no option is removed)

**Removing the *button* does not remove the *option*.** Every current button (`Apply`, `Cancel`, `Refresh`, `Connect`, `Disconnect`, `Forget`, `Install`, `Remove`, `Update`, `Upgrade`, `Regenerate`, `Restore default`, `Reset Defaults`, `Try again`, etc.) stays available as an **Action row** in the list itself, with a translated label, icon, shortcut and the same action as before.

- **Keep the draft model where it exists today.** On the `appearance` pages that edit `surface_draft()` and wait for `Apply` (Taskbar, TaskbarIcons, TaskbarDate, TaskbarTime, WidgetTelemetry, ControlPanel, SurfaceSection, effects), changes remain a draft and are **only applied** when the user activates the **`Apply`** row, the last one in the list, visually separated (an Action row with a confirmation icon and the theme's primary style). Do **not** switch these pages to immediate apply.
- `Apply` is disabled and dimmed (skipped by the cursor) while there are no pending changes. A subtle indicator (for example `●` or "changed") shows that an unapplied draft exists.
- Where `Cancel`/`Discard` existed, keep a **`Cancel`** row (discards the draft and goes back). `Esc` is equivalent to it. With a pending draft, `Esc` asks for confirmation before discarding, using the confirmation component, instead of silently losing changes.
- Where the action is already immediate today (toggles, theme/position/accent choice, `Connect`, `Refresh`...), keep it immediate. Do **not** turn an immediate action into a draft, or a draft into an immediate action.
- Slow operations stay as jobs (`JobManager`), with progress and result in the status bar, without blocking the render loop. Preserve existing validation (`validate_content` and similar) and show the error on the row.
- **Destructive, privileged or hard-to-revert actions** (deleting a theme, forgetting a network, regenerating GRUB, installing/removing packages, touching disks, shutting down): **one single** centralized confirmation component. Layout: title, description, two rows (`Confirm` / `Cancel`), Enter confirms, Esc cancels, `y`/`n` as shortcuts. Remove the three current mechanisms, but keep every confirmation that already exists.
- Suggested row order: fields and options, a separator row, the page's actions (`Apply`, `Refresh`...), and finally `Cancel`/`Back`.
- For buttons that depend on the selected item (`Connect`/`Forget` on a Wi-Fi network, `Install`/`Remove` on a package), show the actions as rows on the item's detail page (or in an actions submenu opened with Enter), keeping one-key shortcuts where they already exist.

### Mandatory inventory (anti-regression)

Before removing any button, generate in `docs/ux-audit.md` a table `crate > screen > current button/option > action performed > new equivalent menu row > shortcut`. At the end of each phase, check the table and mark every item as migrated. **No item may be left without an equivalent.** An option that seems pointless to keep goes into "Decision points", and you ask.

## 3. Informational rows never receive focus

- The cursor **skips** Info rows on `↑/↓/j/k/PgUp/PgDn/Home/End`. The initial selection lands on the first selectable row. Mouse clicks on Info rows are ignored.
- A page with no selectable row enters scroll mode (the current `readonly()` behavior), with no cursor.
- Visual: Info rows use the theme's "dim" color (semantic colors from `argvus-theme`, nothing hardcoded), label on the left and value right-aligned, **without** the `>` marker and **without** an action icon.
- A temporarily invalid row (for example "Rounding" while "Rounded" is off): show it disabled and skip it, instead of leaving it selectable and without effect.

## 4. Semantic, unique icons

- Single source of truth: the icon **belongs to the item** (a field on `Row`/`MenuItem` or an `icon_for(ItemId)` function), never passed by hand in each `format!`. Eliminate `home_icon_for_item(usize)` and any index-based mapping.
- Every **navigable or actionable** item has its own icon that matches its meaning (Taskbar → taskbar/window, Theme → palette, Wallpaper → image, Effects → wand/sparkle, Terminal → terminal, Launcher → rocket/app grid, Widget Telemetry → chart/gauge, Control Panel → sliders/panel, Position top/bottom/left/right → arrows or alignment, Gaps/Thickness/Rounded → spacing/border).
- Two sibling items do **not** share the same icon, unless their meaning is identical.
- **Info** rows get no decorative icon. `INFO`/`STORAGE`/`SUCCESS` stop being wildcards: `INFO` only for actual information, `STORAGE` only for storage, `SUCCESS` only for a success state.
- State icons (`●`, `[x]`) live in the marker column, not mixed with the item icon.
- **Full audit** in `docs/ux-audit.md`: `screen > item > current icon > proposed icon`, for all 18 crates and the Home. The `Appearance > Taskbar` case (currently an HDD icon) is just one example.
- New glyphs go into the `argvus-tui::icons` catalog, one cell wide (Symbols Nerd Font Mono) and honoring `AppConfig::icon()` (returns empty with icons off; rows must stay aligned in both cases). Confirm the glyph exists in `nf-md-*` before using it.

## 5. Contextual help footer

Generate the footer from the selected row's type and the page (`↑↓ navigate · Enter open/activate · Space toggle · Esc back · ? help`), instead of an i18n key written per screen. Show only the keys that apply to the current row. Remove help i18n keys that become unused, in both **en** and **pt-br**.
