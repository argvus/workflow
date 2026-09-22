---
name: argvus-development
description: General implementation, refactoring, debugging, and cross-repository integration workflow for ARGVUS projects under de/.
---

# ARGVUS Development Workflow

Use this skill for implementation work across ARGVUS repositories.

## Workspace

Repositories:

`de/*`

Treat the workspace as an integrated system, not a collection of unrelated projects.

## Before editing

For the requested feature:

1. identify the user-facing entry point;
2. identify all relevant repositories;
3. identify the source of truth;
4. identify runtime consumers;
5. identify persistence;
6. identify generated files;
7. identify reload/apply behavior;
8. identify i18n;
9. identify packaging dependencies.

Do not perform a full workspace audit unless explicitly requested.

Use targeted searches.

## Source-of-truth rule

Prefer:

authoritative state
→ generated/derived state
→ runtime consumers.

Avoid independent copies of the same configuration.

Examples:

keybinding defaults + user overrides
→ generated Hyprland bindings.

input configuration
→ generated Hyprland input config.

appearance state
→ taskbar/control-panel/control-center consumers.

## Cross-repository changes

When a feature crosses repositories, implement the complete path.

Do not stop after only adding UI.

Typical flow:

UI
→ backend/domain model
→ persistence
→ generated/runtime state
→ apply/reload
→ validation.

## User configuration

Respect XDG.

Do not:

- hardcode `/home/<user>`;
- write into HOME from PKGBUILD;
- overwrite user configuration;
- treat generated files as user-owned source.

Use the project's existing XDG helpers and ARGVUS config conventions.

## Runtime behavior

Do not assume successful command execution means the feature works.

When practical, verify:

- effective state;
- reload result;
- service state;
- D-Bus state;
- Hyprland state;
- real UI state.

Use read-back where appropriate.

## Error handling

User-facing applications must not expose raw implementation errors as the only UX.

Prefer:

friendly message
+
technical log.

Do not silently ignore persistent-state errors.

## Async/background work

Do not block TUI/QML render loops with:

- D-Bus calls;
- subprocess execution;
- filesystem scans;
- compression;
- long reloads.

Use the existing async/thread/job pattern.

Avoid introducing a new runtime when one already exists.

## Debounce / coalescing

For sliders, toggles, color pickers, repeated key actions, or rapidly changing state:

- avoid one expensive reload per input event;
- debounce or coalesce;
- apply final state deterministically;
- prevent stale operations from overwriting newer state.

## Generic implementation

Do not implement hardware/model/vendor-specific behavior when a capability-driven
API exists.

Prefer:

capabilities
→ generic model
→ dynamic UI.

## Tests

Add regression tests for bugs fixed.

Prefer testing:

- parsing;
- normalization;
- state transitions;
- merge logic;
- persistence;
- fallback behavior;
- idempotent refresh;
- invalid state.

Do not create huge architectural abstractions solely to make mocking possible.

## Documentation synchronization

Every implementation change under `de/` must include a documentation impact check.

Before completing the task:

1. identify whether the implementation changed user-visible or contributor-visible behavior;
2. inspect the relevant documentation under `web/site-src/`;
3. update it when necessary;
4. use the `argvus-documentation` skill for documentation work;
5. validate the documentation site when files were changed.

Examples that require documentation review:

- new feature;
- changed UI/UX behavior;
- new setting;
- changed default;
- new CLI command;
- changed path;
- changed config schema;
- new generated file;
- changed service;
- changed reload behavior;
- new hardware capability;
- changed dependency;
- changed packaging/install behavior.

Do not update documentation merely because source code was reformatted or an
internal implementation detail changed without affecting users or contributors.

Do not consider a user-facing feature complete while the corresponding
documentation remains stale.

## Completion

A feature is not complete merely because:

- it compiles;
- backend code exists;
- route exists;
- tests pass.

If it is user-facing, verify the actual installed/runtime flow when feasible.

A user-facing implementation task is complete only when:

implementation
+
runtime validation
+
relevant documentation synchronization

are all complete.

## Final report

Include:

- repositories touched;
- source of truth;
- user-visible result;
- persistence;
- runtime application;
- tests;
- packaging changes;
- remaining limitations.