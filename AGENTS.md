# ARGVUS Workspace

This workspace contains the source repositories of the ARGVUS desktop shell,
its supporting packages, and the source code of the ARGVUS website/documentation.

## Workspace root

`/home/boss/Projects/github/organizations/argvus`

## Workspace layout

Desktop/session projects:

- `de/`

Web projects:

- `web/`

Documentation website:

- `web/site-src/`

Local Codex skills:

- `.codex/skills/`

## ARGVUS project model

ARGVUS is composed of many integrated repositories.

Projects under `de/` are not isolated applications. A user-facing feature may
cross several repositories.

Examples:

- settings UI;
- Hyprland integration;
- session startup;
- generated configuration;
- themes and appearance;
- taskbar;
- control panel;
- notifications;
- networking;
- input;
- i18n;
- greeter/login;
- splash/handoff;
- packaging.

When implementing or debugging a feature, trace the complete feature path across
all relevant repositories.

Do not assume the repository where the UI lives owns the complete feature.

## Skills

Use the local skills under `.codex/skills/` according to the task.

### Documentation

IMPORTANT:

For user-facing changes under `de/`, documentation synchronization is part of the definition of done, not a separate optional follow-up task.

Use:

`.codex/skills/argvus-documentation/SKILL.md`

for documentation auditing, creation, reorganization, or updates.

### General ARGVUS implementation

Use:

`.codex/skills/argvus-development/SKILL.md`

for implementation, refactoring, debugging, repository integration, and general
changes under `de/`.

### Rust and Arch Linux packaging

Use:

`.codex/skills/argvus-rust-packaging/SKILL.md`

when working with:

- Rust workspaces;
- Cargo;
- PKGBUILD;
- Makefile;
- `.pkg.tar.zst`;
- `skeleton-rs-pkg`;
- `skeleton-pkg`;
- packaging validation.

### Hyprland

Use:

`.codex/skills/argvus-hyprland/SKILL.md`

when a task involves:

- `argvus-hyprland`;
- Lua configuration;
- Hyprland bindings;
- generated Hyprland configuration;
- input;
- monitors;
- workspaces;
- dispatchers;
- reload behavior.

### User interfaces

Use:

`.codex/skills/argvus-ui/SKILL.md`

when changing:

- `argvus-control-center`;
- `argvus-control-panel`;
- taskbar;
- widgets;
- TUI UX;
- Ratatui;
- Quickshell/QML;
- Waybar layout or presentation.

### Internationalization

Use:

`.codex/skills/argvus-i18n/SKILL.md`

when adding or changing user-visible strings or translation behavior.

### Session / system integration

Use:

`.codex/skills/argvus-session-integration/SKILL.md`

for:

- `argvus-session`;
- greetd;
- greeter;
- splash handoff;
- systemd user services;
- D-Bus;
- startup;
- reload;
- session readiness.

### Web

Use:

`.codex/skills/argvus-web/SKILL.md`

for work under:

`web/`

including Astro/Starlight and other web projects.

Multiple skills may apply to the same task.

Example:

A new Mouse & Touchpad feature may require:

- argvus-development;
- argvus-ui;
- argvus-hyprland;
- argvus-i18n;
- argvus-rust-packaging.

## Sources of truth

Use the following priority when determining how ARGVUS currently works:

1. Current source code.
2. Runtime configuration and generated configuration code.
3. Packaging files such as PKGBUILD.
4. Cargo.toml, package.json and other dependency manifests.
5. systemd units, D-Bus interfaces, desktop files and service definitions.
6. installation scripts and Makefiles.
7. project configuration files.
8. tests.
9. README files.
10. Git history/issues/PRs only when historical context is necessary.

Never assume a feature exists solely because it appears in documentation or README.

## Repository discovery

Repositories under `de/` include:

- `argvus`
- `argvus-accounts`
- `argvus-app-profiles`
- `argvus-appearance`
- `argvus-control-center`
- `argvus-control-panel`
- `argvus-display`
- `argvus-firewall`
- `argvus-fonts`
- `argvus-greeter`
- `argvus-hyprland`
- `argvus-i18n`
- `argvus-icons`
- `argvus-launcher`
- `argvus-lock`
- `argvus-network`
- `argvus-notifications`
- `argvus-portal`
- `argvus-power`
- `argvus-removable-devices`
- `argvus-session`
- `argvus-splash`
- `argvus-system-monitor`
- `argvus-taskbar`
- `argvus-taskbar-calendar`
- `argvus-terminal`
- `argvus-theme-splash`
- `argvus-tui`
- `argvus-wallpapers`
- `argvus-waybar`
- `argvus-widget-telemetry`

Do not assume all repositories use the same language or build system.

Inspect the repository before selecting commands.

## Cross-project analysis

Before implementing a feature:

1. identify the user-facing entry point;
2. identify the configuration source of truth;
3. identify runtime consumers;
4. identify generated files;
5. identify reload/apply mechanisms;
6. identify i18n requirements;
7. identify packaging dependencies;
8. identify tests.

Avoid implementing the same state independently in multiple repositories.

Prefer:

single source of truth
→ derived/generated state
→ consumers.

## Documentation synchronization

Any user-facing change made under:

`de/`

must be evaluated for corresponding documentation changes under:

`web/site-src/`

This applies to:

- new features;
- changed behavior;
- new or changed configuration;
- new CLI commands or flags;
- new UI pages or controls;
- changed keybindings;
- changed paths;
- changed services;
- changed dependencies;
- changed installation behavior;
- changed session behavior;
- changed theme/appearance behavior;
- changed troubleshooting procedures;
- removed or renamed functionality.

The implementation and documentation should be updated in the same task whenever
the change affects information that users or contributors need to know.

Do not postpone obvious documentation updates to a separate future task unless the
user explicitly asks to modify implementation only.

After modifying a project under `de/`:

1. determine whether the change affects public/user/developer documentation;
2. locate the relevant documentation under `web/site-src/`;
3. update existing documentation or create the necessary section/page;
4. update internal cross-links/navigation when needed;
5. validate the documentation site.

Do not create documentation for purely internal changes that have no meaningful
user-facing or contributor-facing impact.

Examples of changes that normally require documentation updates:

- adding a new Control Center setting;
- adding or changing a CLI route;
- changing a configuration path;
- adding a generated file;
- changing a keybinding;
- adding a new service or daemon;
- changing theme behavior;
- changing login/session startup;
- adding hardware support;
- changing package dependencies;
- adding new troubleshooting requirements.

The source implementation remains authoritative. Documentation must describe the
final implementation produced by the task.

## User configuration contract

Respect the ARGVUS configuration model.

System-owned defaults belong under system paths such as:

- `/usr/share/argvus`
- `/usr/lib/argvus`
- `/etc` when appropriate.

User-owned configuration belongs under XDG locations, typically:

- `$XDG_CONFIG_HOME/argvus`
- `$XDG_DATA_HOME/argvus`
- `$XDG_CACHE_HOME/argvus`

Generated files must remain derived state.

Do not make package installation write into `$HOME`.

Do not overwrite user configuration during package upgrades.

## Generated files

Generated configuration is not the source of truth.

When modifying systems that generate runtime files:

- identify the source config;
- modify the source model;
- regenerate;
- validate;
- apply/reload.

Do not instruct users or implementation code to edit generated files directly
unless the project explicitly defines them as user-editable.

## Internationalization

All user-facing strings in ARGVUS components should use `argvus-i18n` when the
component is integrated with that system.

Do not introduce new hardcoded visible strings without checking i18n support.

Use:

- en-US as canonical fallback;
- pt-BR as supported translation.

Keep translation keys semantic and consistent.

## UX

ARGVUS interfaces are keyboard-first where applicable.

Preserve:

- predictable navigation;
- consistent footer/help hints;
- readable focus states;
- consistent icons;
- responsive layouts;
- safe cancellation/back behavior.

Do not create modal complexity when a dedicated page is clearer.

## Packaging

Do not casually alter packaging structure.

For Rust projects based on `skeleton-rs-pkg`:

- preserve skeleton conventions;
- preserve Makefile behavior unless explicitly asked to change it;
- avoid unnecessary recompilation;
- validate PKGBUILD and package output.

For Arch-only packaging projects based on `skeleton-pkg`, preserve that structure.

## Git safety

There may be uncommitted work.

Never:

- discard unrelated changes;
- reset repositories;
- clean untracked files;
- force checkout;
- rewrite history;
- force push.

Do not commit unless explicitly instructed.

## Validation

Use project-specific validation.

Common checks may include:

- `cargo fmt --all -- --check`
- `cargo check --workspace`
- `cargo clippy`
- `cargo test`
- `cargo build --release`
- `make validate`
- `make build`
- `makepkg --printsrcinfo`
- `luac -p`
- `sh -n`
- `shellcheck`
- `qmllint`
- `argvus-i18n validate`
- `git diff --check`

Do not run irrelevant expensive validation across all repositories by default.

Validate affected repositories and direct consumers.

When a task modifies `de/` and requires documentation synchronization, also validate
the affected documentation under `web/site-src/`.

A development task is not complete if the implementation changed documented
behavior but the relevant documentation was left stale.

## Final report

At the end of an implementation task, report:

- repositories analyzed;
- repositories modified;
- architecture decisions;
- source of truth used;
- files changed;
- runtime/application behavior;
- i18n changes;
- packaging changes;
- tests and validation executed;
- hardware/session validation when applicable;
- real remaining limitations.

Do not describe planned work as completed.

When implementation under `de/` changed documented behavior, also report:

- documentation pages updated;
- documentation pages created;
- documentation intentionally left unchanged and why.