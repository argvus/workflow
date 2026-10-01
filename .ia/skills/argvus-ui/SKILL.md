---
name: argvus-ui
description: UX/UI workflow for ARGVUS TUI, Quickshell/QML, Waybar, taskbar, control center, control panel, and widgets.
---

# ARGVUS UI Workflow

Use this skill for user-facing UI changes.

## UI families

ARGVUS contains multiple UI technologies:

- Ratatui/Crossterm TUI;
- Quickshell/QML;
- Waybar;
- shell/system UI.

Do not apply assumptions from one toolkit to another.

## General UX rules

Prefer:

- clear hierarchy;
- predictable navigation;
- dedicated pages over cramped modals;
- consistent focus;
- consistent footer/help;
- responsive layouts;
- minimal empty space;
- semantic grouping;
- readable status.

## TUI

For Ratatui screens:

- headers and informational rows are not focusable;
- focusable indices must be separate from visual rows;
- Esc must have deterministic navigation behavior;
- preserve selection by stable ID across refresh/resize;
- avoid blocking render;
- support terminal resize;
- show a clear fallback for very small terminals.

## Search

Search should:

- filter by user-visible text;
- preserve stable selection when possible;
- not duplicate rows after refresh;
- avoid raw internal IDs as primary labels.

## Cards/grids

For dashboard-like screens:

- calculate layout centrally;
- support multiple width breakpoints;
- do not hardcode one terminal size;
- keep navigation independent of rendering layout.

## Quickshell/QML

Use existing components and theme tokens.

Avoid large new dependencies for small UI needs.

For continuous controls:

- debounce global application;
- avoid service restart per pixel/input event;
- keep local preview responsive.

## Icons

Use the established ARGVUS icon system.

Do not mix emoji with icon fonts unless the project explicitly does so.

Reserve consistent icon width and spacing.

## Color

Do not hardcode theme colors if token/theme abstraction exists.

For user-chosen highlight colors, calculate readable foreground where needed.

## User-visible labels

Prefer action-oriented labels.

Example:

`Open terminal`

rather than only:

`Terminal`

when the meaning is an action.

## Error/status UI

Do not render backend result values such as `ok` as arbitrary field content.

Success messages belong in status/toast/footer state.

Error messages should be friendly and contextual.

## Refresh/idempotency

UI refresh must be idempotent.

Repeated refresh must not duplicate rows, watchers, timers, or subscriptions.

## Final validation

Test:

- normal navigation;
- Esc/back;
- repeated actions;
- resize;
- search;
- focus;
- installed/runtime build;
- en-US/pt-BR when applicable.