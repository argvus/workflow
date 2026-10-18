---
name: argvus-control-center-paths
description: Keeps the navigation paths (breadcrumbs) of the ARGVUS Control Center correct when adding or editing a Home destination or a settings page. Use whenever a feature is added, moved, renamed or reached from a new entry point (Home, global search, CLI route, or a link inside another page) in de/argvus-control-center.
---

# ARGVUS Control Center: navigation paths

A page's breadcrumb is the path the user followed to reach it. It must show the
Home card the page is listed under, then the item, then any sub-pages:

```
Control Center > <Card> > <Item>
Control Center > <Card> > <Item> > <Sub-page>
```

The shell already draws `Control Center >` in front of every domain page
(`argvus_tui::page::shell`). The `settings` crate draws its own header and
includes the root in its strings. Do not add `Control Center` twice.

Recurring bugs this skill prevents:

- A page shows only its own name (`Control Center > Displays`), without its card.
- A page shows a card that is not where it is listed (`Language & Region > Date & Time`
  when Date & Time is a Preferences item).
- A page shows a retired card name (`Desktop Shell`, `Security`, `Applications`, `General`).
- A Home item opens a page whose data never loads (Firewall showed only the Reload row).

## Source of truth

1. The Home catalog: `de/argvus/crates/argvus-control-center/src/home/catalog.rs`.
   It decides which card lists each destination, its label key and its icon.
2. The card title keys (`control_center.card_*`, plus `control_center.appearance` and
   `control_center.preferences`). The breadcrumb must use the same key the card header uses.
3. The dispatch: `open_destination` in `crates/argvus-control-center/src/app.rs`.
4. The breadcrumb of the page itself, in its crate (see the table below).

Never invent a card name in a breadcrumb. Copy the key from `catalog.rs`.

## Current cards and their keys

| Card (title shown) | Key | Items (Home label) |
| --- | --- | --- |
| Appearance | `control_center.appearance` | Fonts, Desktop Style, Application Style, Taskbar, Control Center, Widget telemetry |
| Desktop & Input | `control_center.card_desktop_input` | Hyprland, Displays, Keyboard & Shortcuts, Mouse & Touchpad, Window rules |
| Preferences | `control_center.preferences` | Language & Region, Date & Time, Default Apps, Power, Session |
| Hardware & Connectivity | `control_center.card_hardware` | Hardware Overview, Network & Wi-Fi, Bluetooth, Audio, Storage |
| System Administration | `control_center.card_system` | Packages, Services, Boot, Hostname, Users & Groups, Firewall, Notifications |
| Tools & Diagnostics | `control_center.card_tools` | Projects, Snippets, SSH keys, GPG keys, Developer Services, Diagnostics, About ARGVUS |
| (below the cards) | `control_center.settings` | Settings: Language, Style |

Settings (`Route::AppSettings`) is not a card. Its pages read
`Control Center > Settings > <Page>`.

## Expected breadcrumbs for the current pages

These are asserted by tests and must not change without updating the tests and
the documentation.

| Page | Breadcrumb |
| --- | --- |
| Hyprland (Home) | `Desktop & Input > Hyprland` |
| Displays | `Desktop & Input > Displays` |
| Keyboard Shortcuts | `Desktop & Input > Keyboard Shortcuts` |
| Window rules | `Desktop & Input > Window rules` |
| Mouse & Touchpad | `Desktop & Input > Mouse & Touchpad` |
| Language & Region (hub) | `Preferences > Language & Region` |
| Time Zone, Regional locale, System locales, Keyboard | `Preferences > Language & Region > <Page>` |
| Date & Time | `Preferences > Date & Time` (shallow, even when opened from the Language & Region hub) |
| Default Apps | `Preferences > Default Apps` |
| Power, Session | `Preferences > Power`, `Preferences > Session` |
| Interface language | `Settings > Language` |
| Style | `Settings > Style` |
| Hardware Overview | `Hardware & Connectivity > Hardware Overview` |
| Network & Wi-Fi | `Hardware & Connectivity > Network & Wi-Fi` |
| Audio, Storage, Bluetooth | `Hardware & Connectivity > <Item>` |
| Packages, Services, Boot | `System Administration > <Item>` |
| Hostname | `System Administration > Hostname` |
| Users & Groups | `System Administration > Users & Groups` |
| Users, Groups (under the hub) | `System Administration > Users & Groups > Users` (or `> Groups`) |
| Firewall | `System Administration > Firewall` |
| Notifications | `System Administration > Notifications` |
| Developer Services | `Tools & Diagnostics > Developer Services` |
| Diagnostics, About | `Tools & Diagnostics > <Item>` |
| Projects, Snippets, SSH keys, GPG keys | `Tools & Diagnostics > <Item>` |

## Where each breadcrumb is built

- Settings pages: `breadcrumb()` in `crates/argvus-control-center-settings/src/app.rs`.
  The roots are `category_root(...)` values (for example `desktop_input_root`,
  `tools_root`, `system_root`) and `language_root`. A new page gets its own match arm
  built from one of those roots.
- Domain crates (displays, session, power, hardware, network, audio, storage,
  packages, services, boot, dev-services, diagnostics, appearance): `breadcrumb()`
  in each crate's `ui.rs`. Their root is `format!("{} > {}", card, item)`. Power
  has no breadcrumb function; its path is built where `shell(...)` is called.
- Hyprland: `breadcrumb()` in `crates/argvus-control-center/src/hyprland.rs`.
- Control Center settings (Style): `breadcrumb()` in `config_app.rs`.

## Checklist: adding or moving a destination

Do all of these in the same change. Each step is a path that users reach.

1. **Catalog** (`home/catalog.rs`): add the `HomeDestination` variant, its
   `glyph()` arm, and an item in the right card (or a `Standalone` row). Keep feature
   gates identical on the variant, the glyph arm, the item push and the dispatch arm.
   Do not leave an orphan `#[cfg(...)]` line behind when you delete a variant.
2. **Dispatch** (`open_destination` in `app.rs`): one arm per variant with the same gate.
3. **Breadcrumb** in the page's crate, using the card key from the table above. Use
   the card of the Home entry, not the card of another entry point.
4. **Search** (`app.rs`, the `entries` array and `open_search_route`): the search category must be
   a card key or a page name that exists in the locale files, and the route
   string must have a matching arm.
5. **CLI route** (`cli.rs`): the route must open the same page as the Home entry.
   If the page changes, update the route and say so in the documentation.
6. **i18n** (`de/argvus/locales/en-US` and `pt-BR`): add every label and card key.
   Both files must have the same key set.
7. **Data loading**: a page opened from any entry point must load its data on open.
   For administration pages, call `App::enter_page` / `Administration::ensure_loaded`
   from `open_settings`, so Home, search and CLI all load it.
8. **Tests**: add the new page to `breadcrumbs_show_the_home_card_of_each_page`
   (settings) or to the crate's breadcrumb test. Update catalog tests if the card
   layout changed.
9. **Documentation**: update `docs/en/index.md`, `docs/pt-br/index.md` and
   `docs/ux-audit.md` (the path in the description of the card and the entry point).

## Rules for changing an existing path

- If a destination moves to another card, change its breadcrumb in the same change
  and update the expected value in the test. Do not leave the old path behind.
- If a page is nested under a different parent, its sub-pages must follow the new
  parent. Check every `format!` that uses the old root.
- Do not show a parent that the Home does not list. `Date & Time` belongs to
  Preferences, not to Language & Region, even though the Language & Region hub links to it.
- Retired names must not appear in code, strings or docs: `Desktop Shell`, `Security`
  (as a card), `Applications` (as a card), `General` (as a card), `Interface Language`
  as a Preferences item, `Configuration` as a Preferences item.

## Validation

Run from `de/argvus`:

```sh
ARGVUS_I18N_DIR=<workspace>/de/argvus/locales cargo test --workspace --no-fail-fast
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo fmt --all -- --check
```

`ARGVUS_I18N_DIR` is required in tests, because the installed catalog in
`/usr/share/argvus/i18n` may not have the new keys yet. Check the key parity of the
two locale files as well: every key in `en-US/control-center.json` must exist in `pt-BR/control-center.json`, and the reverse.

Tests must never run real system commands (`nmcli`, `pkexec`, `systemctl`, and
so on). For loading tests, use the fakes already used by the crate.

## Anti-patterns

- Building a breadcrumb only from the page's own i18n key.
- Copying a card label as plain text instead of using its key, so it drifts from the Home.
- Adding a Home item without the matching search entry, or without the dispatch arm.
- Adding a page that the Home can open but whose data is loaded only at construction.
- Leaving a page reachable only from Settings without the path it used to have, when
  the Home is the documented entry point.
