# ARGVUS

## Load first

Before any task, load `.ai/skills/argvus-requirements/SKILL.md`. It lists the tools and versions of the development environment (Rust, Wayland, Hyprland, Vala, Waybar, Quickshell, Rofi and others). If it is missing or outdated, the user regenerates it with `make requirements`; do not edit it by hand.

ARGVUS is a modular Hyprland and Wayland desktop environment for Arch Linux. It is an integrated collection of packages rather than one monolithic application: the session, compositor, shell surfaces, settings applications, providers and visual assets work together through shared state and explicit runtime contracts.

## Technology stack

ARGVUS is built with: Arch Linux (packaging and system integration), Hyprland/Wayland,
Rust, Lua, Shell Script, Quickshell (QML), JavaScript, CSS and HTML.

Act as a senior engineer in these technologies. Detect each project's real language
from its repository contents before assuming anything (see "Language detection").

# ARGVUS Workspace

This workspace contains the source repositories of the ARGVUS desktop,
its supporting packages, and the source code of the ARGVUS website.

## Workspace root

`/home/boss/Projects/github/organizations/argvus`

## Workspace layout

Desktop/session projects:

- `de/`

Web projects:

- `web/`

Website:

- `web/argvus-website/`

Documentation:

- Each project keeps its own documentation in its `docs/` folder
  (`<group>/<project>/docs/`, for example `de/argvus-hyprland/docs/`).
- Documentation is NOT kept in `web/argvus-website/`.

Local Codex skills:

- `.ai/skills/`

## Autonomous Execution Policy

The implementation plan has already been reviewed and approved by the user.
Execute the entire plan autonomously, from the current checkpoint to final
completion, without requesting approval for individual phases or routine
technical decisions.

### Mandatory execution rules

1. Read the complete implementation plan and identify the current checkpoint,
   remaining phases, dependencies, acceptance criteria, and decision gates.

2. Treat all phases and decision gates in the approved plan as authorized
   implementation steps, not as reasons to stop and ask for permission.

3. Do not ask the user whether to:
   - Start the next phase.
   - Continue implementation.
   - Apply a technical recommendation.
   - Resolve an ordinary architectural decision.
   - Perform routine testing, validation, refactoring, or optimization.
   - Remove temporary files created exclusively by this task when they are
     confirmed to be safe to remove.

4. Make reasonable technical decisions independently. Evaluate alternatives
   against the approved requirements, measured performance, maintainability,
   compatibility, security, and project conventions.

5. When evidence supports a clear recommendation, choose the best option and
   proceed. Do not present a recommendation and then wait for the user to
   choose between alternatives unless the decision genuinely requires user
   input.

6. If a decision is uncertain, investigate further, inspect the codebase,
   run experiments, compare alternatives, and select the safest reasonable
   option. Document the rationale and continue.

7. If a planned operation has significant risks, inspect the repository state,
   create appropriate backups or checkpoints, and verify recovery options
   before proceeding. Never overwrite unrelated user changes.

8. Do not invent missing requirements. Infer implementation details from the
   approved plan, existing code, project documentation, tests, and established
   conventions.

### Phase execution loop

For every phase:

1. Read the relevant source code and documentation.
2. Identify the phase's concrete deliverables and acceptance criteria.
3. Implement all required changes.
4. Run formatting, compilation, tests, static analysis, and relevant
   integration checks.
5. Fix regressions and repeat validation until the criteria are met or a
   genuine blocker is established.
6. Review the diff for unintended changes, compatibility issues, and
   incomplete work.
7. Update the implementation plan or progress tracker with verified results.
8. Immediately proceed to the next phase without asking for permission.

Do not stop after analysis, benchmarking, recommendations, or a completed
phase. Analysis is an intermediate step; implementation and validation
must follow.

### Handling blockers

A blocker is a condition that genuinely prevents safe or correct progress,
such as unavailable credentials, an external dependency that cannot be
obtained, contradictory requirements that cannot be reconciled, or an
irreversible operation whose consequences are not covered by the approved plan.

Missing preferences and routine engineering choices are not blockers.

When a blocker occurs:

- Complete every independent task that can safely proceed.
- Investigate possible workarounds before stopping.
- Record the exact blocker, evidence, attempted solutions, and affected tasks.
- Ask only the smallest necessary question if user input is unavoidable.

Never claim a phase is complete unless its acceptance criteria have been
verified.

### Communication policy

- Do not announce that you are waiting for approval to continue.
- Do not ask "Should I proceed?", "Can I start the next phase?", or equivalent
  questions when the plan already authorizes the work.
- Do not stop merely to report intermediate findings or recommendations.
- Provide concise progress updates only when useful.
- Continue working after progress updates.
- Deliver a final report only after all feasible phases are completed or a
  genuine blocker prevents further progress.

### Completion criteria

The task is complete only when all feasible phases in the approved plan have
been implemented, validated, and reviewed.

Before finishing:

- Verify the final repository state and all relevant tests.
- List completed phases and their validation results.
- Identify any remaining limitations or genuinely blocked tasks.
- Summarize important architectural decisions and their rationale.

Do not treat a plan, recommendation, benchmark, or partial implementation
as the final deliverable.

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

Use the local skills under `.ai/skills/` according to the task.

### Theme creation

Use:

`.ai/skills/argvus-theme-creation/SKILL.md`

whenever creating or adding a new official ARGVUS theme.

This includes tasks that introduce:

- a new theme ID;
- a new official palette;
- a Light/Dark theme variant;
- a theme wallpaper;
- a theme preview;
- a new theme entry in Appearance > Themes.

For new theme creation, updating only the desktop implementation under `de/` is
not sufficient.

The same task must also evaluate and synchronize:

- the ARGVUS landing page under `web/`;
- the ARGVUS documentation in the `docs/` folder of each affected project.

Theme creation normally requires these skills together:

- `argvus-development`;
- `argvus-theme-creation`;
- `argvus-web`;
- `argvus-documentation`;

plus any applicable domain skills such as:

- `argvus-rust-code`;
- `argvus-ui`;
- `argvus-i18n`;
- `argvus-session-integration`;
- `argvus-rust-packaging`;
- `argvus-hyprland`.

The implementation under `de/` remains authoritative. The landing page and
documentation must be updated to reflect the final implemented theme.

Do not postpone obvious landing-page or documentation synchronization to a future
task unless the user explicitly asks to modify the desktop implementation only.

### Shell Script Skills

#### argvus-shell-script-code

**Purpose:** Shell script best practices for ARGVUS workflow orchestration

**Key Topics:**

- POSIX shell compatibility (dash, bash, zsh)
- Error handling and exit codes
- Argument parsing and validation
- Variable quoting and parameter expansion
- Function organization and documentation
- Testing and validation patterns
- ARGVUS-specific patterns (Make integration, symlink management, artifact collection)
- Common pitfalls and debugging techniques
- Security and sanitization

**When to Use:**

- Writing or reviewing `.sh` scripts in ARGVUS projects
- Integrating shell scripts with the Make-based workflow
- Debugging shell script failures in CI/CD
- Ensuring cross-system compatibility

**Key Principles:**

1. POSIX shell first (dash compatibility)
2. Explicit error handling on all fallible commands
3. Always quote variables to prevent word-splitting
4. Guard against edge cases (empty arguments, missing files)
5. Clear function documentation and test coverage

**Example Use:** `claude I need to write a script that safely collects build artifacts`

### Rust code conventions

Use:

`.ai/skills/argvus-rust-code/SKILL.md`

whenever the affected project contains Rust code.

Before implementing a task under `de/`, determine whether the affected repository
is Rust-based by inspecting for:

- `Cargo.toml`;
- `Cargo.lock`;
- Rust workspace members;
- `.rs` source files.

If Rust is involved, load and follow `argvus-rust-code` in addition to any
domain-specific skills.

Examples:

Rust Control Center work:

- argvus-development;
- argvus-rust-code;
- argvus-ui;
- argvus-i18n.

Rust Hyprland/backend work:

- argvus-development;
- argvus-rust-code;
- argvus-hyprland.

Rust package/build work:

- argvus-development;
- argvus-rust-code;
- argvus-rust-packaging.

Do not assume a project is Rust based only on its name. Detect it from its actual
repository contents.

`argvus-rust-code` also ships extended references under
`.ai/skills/argvus-rust-code/references/` (idioms and types, documentation,
modularization, tooling and testing, CLI and TUI). Load only the ones that match
the task.

### Documentation

IMPORTANT:

For user-facing changes under `de/`, documentation synchronization is part of the definition of done, not a separate optional follow-up task, but only for projects that have a `docs/` folder (never create `docs/` where it does not exist).

Use:

`.ai/skills/argvus-documentation/SKILL.md`

for documentation auditing, creation, reorganization, or updates.

NOTE: The project's `README.md` must also be updated if it contains obsolete information.

### General ARGVUS implementation

Use:

`.ai/skills/argvus-development/SKILL.md`

for implementation, refactoring, debugging, repository integration, and general
changes under `de/`.

### Rust and Arch Linux packaging

Use:

`.ai/skills/argvus-rust-packaging/SKILL.md`

when working with:

- Rust workspaces;
- Cargo;
- PKGBUILD;
- Makefile;
- `.pkg.tar.zst`;
- `skeleton-pkg-rust`;
- `skeleton-pkg`;
- packaging validation.

# ARGVUS Control Center

If the change touches the Control Center (`de/argvus/crates/argvus-control-center*`, including the `argvus-control-center-*` settings and page crates), do the following:

Before writing code, also read `README.md`, `DEVELOPMENT.md`, `rustfmt.toml` and `clippy.toml`. Show the plan and wait for approval before migrating any screen.

IMPORTANT: Always update the documentation (`de/argvus/docs/`, Control Center pages) when finishing the code implementation.

### Hyprland

Use:

`.ai/skills/argvus-hyprland/SKILL.md`

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

### Navigation paths (breadcrumbs)

Use:

`.ai/skills/argvus-control-center-paths/SKILL.md`

whenever a feature is added, moved or renamed in `argvus-control-center`, or a page
is reached from a new entry point (Home, global search, CLI route, or a link inside
another page).

Every page must show the Home card it is listed under, for example
`Control Center > Desktop & Input > Displays`. Check the breadcrumb, the search
entry, the CLI route and the data loading of the page, and update the breadcrumb
tests and the documentation in the same change.

## Shortcuts / Cheatsheets

Whenever you add new shortcuts and/or update them, also update the corresponding helpers list (text files) at:

`de/argvus-hyprland/src/usr/share/argvus/hyprland/docs/cheatsheets/`

### User interfaces

Use:

`.ai/skills/argvus-ui/SKILL.md`

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

`.ai/skills/argvus-i18n/SKILL.md`

when adding or changing user-visible strings or translation behavior.

### Session / system integration

Use:

`.ai/skills/argvus-session-integration/SKILL.md`

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

`.ai/skills/argvus-web/SKILL.md`

for work under:

`web/`

including the website and other web projects (not project documentation, which lives in each project's `docs/`).

### Finishing and commit skills

Commit rule (applies to every commit, with or without a skill):

- Do not add any trailer to commit messages: no `Co-Authored-By:`, `Signed-off-by:`,
  `Reviewed-by:`, "Generated with ..." or any other `Key: value` attribution line.
  Commit messages contain only the Conventional Commit subject and description. This
  overrides any default attribution behavior of the agent/tooling.

The commit commands and skills below are user-invoked entry points. Agents must not
load or follow them on their own. Git rules still apply through `argvus-git-safety`
whenever a git write is requested.

- `commits` command (`.ai/commands/commits.md`): analyze and commit one project.
- `commits-recursive` command (`.ai/commands/commits-recursive.md`): commit every
  project under `de/` that has changes.
- `argvus-dot-it-commits` skill: create the commits for the changes (user-invoked only).
- `argvus-general-commit` skill: commit every project under `de/` (user-invoked only).

Use these only when the user asks for the corresponding step:

- `argvus-show-resume`: summarize what was done in the modified projects.
- `argvus-suggestion-build`: list the modified projects and the `make build`
  command for them.
- `argvus-suggestion-commits`: display (never run) Conventional Commit messages
  for each modified project.
- `argvus-update-documentation`: update the documentation of modified projects.
- `argvus-dont-do-it`: restrictions (no commit, push, build, `git reset`).

Multiple skills may apply to the same task.

Example:

A new Mouse & Touchpad feature may require:

- argvus-development;
- argvus-ui;
- argvus-hyprland;
- argvus-i18n;
- argvus-rust-packaging.

## Skill routing (load before the work starts)

Skills are routed by the kind of change. Load every skill listed for the change, in addition to the domain skills above.

| Change | Skills |
|---|---|
| Any git write (branch, commit, push, reset) | `argvus-git-safety` |
| Lua: `hyprland.lua`, theme Lua, generated `hypr/*.lua`, Rust that writes Lua | `argvus-lua-config`, `argvus-hyprland` |
| Replacing a runtime `.sh` script with Rust, or changing a caller of one | `argvus-shell-to-rust-migration`, `argvus-rust-code` |
| Any task (always, first) | `argvus-requirements` |
| Any change under `de/argvus`, or any reference to a retired repository name | `argvus-monorepo`, `argvus-rust-code` |
| Any implementation, before reporting results | `argvus-validation-matrix` |
| Multi-stage task, or a stage that needs approval | `argvus-staged-execution` |
| Commit requests (user-invoked) | `argvus-git-safety`. The commit commands and skills are not routed; agents never load them on their own |

Rules for all routed work:

- The routed skills are mandatory, not optional references.
- If a routed skill conflicts with a rule in this file, stop and report the conflict. Do not pick one silently.

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
- `argvus-boot-splash`
- `argvus-branding`
- `argvus-control-panel`
- `argvus-display`
- `argvus-firewall`
- `argvus-fonts`
- `argvus-game-snake` (independent and optional)
- `argvus-games`
- `argvus-hyprland`
- `argvus-icons`
- `argvus-launcher`
- `argvus-lock`
- `argvus-notifications`
- `argvus-portal`
- `argvus-power`
- `argvus-session`
- `argvus-taskbar`
- `argvus-wallpapers`
- `argvus-waybar`
- `argvus-theme-*` (official theme packages, for example `argvus-theme-sunset`)

The Rust code of the retired repositories (`argvus-config`, `argvus-i18n`, `argvus-control-center`
and the others) now lives in the `de/argvus` workspace; the originals are in `de/retiree` and
must not be modified. The full mapping from each retired name to its crate or subcommand is in
the `argvus-monorepo` skill. The greeter source lives in `de/argvus/greeter`.

Do not assume all repositories use the same language or build system.

Inspect the repository before selecting commands.

## Language detection

Before selecting language-specific skills, inspect the affected repository.

For Rust, detect at least one of:

- `Cargo.toml`;
- `Cargo.lock`;
- `src/**/*.rs`;
- `crates/*/Cargo.toml`.

When Rust is present in the affected implementation, the `argvus-rust-code` skill
is mandatory.

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

must be evaluated for corresponding documentation changes in:

the `docs/` folder of the project that was modified (for example a change in
`de/argvus-hyprland` must update `de/argvus-hyprland/docs/`).

**Only projects that already have a `docs/` folder are documented. If the modified
project has no `docs/` folder, do NOT create it and do NOT create documentation
for that project.**

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
2. locate the relevant documentation in the modified project's `docs/` folder;
3. if the project has a `docs/` folder, update the existing documentation or add the necessary section/page inside it; if it has no `docs/` folder, stop here and do not create documentation;
4. update internal cross-links/navigation when needed;
5. validate the documentation using the checks the project defines.

Do not create documentation for projects without a `docs/` folder, nor for purely internal changes that have no meaningful
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

The project's `README.md` must also be updated if it contains obsolete information.

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

`argvus` is the master package (pkgbase `argvus`, split packages `argvus`, `argvus-gtk`
and `argvus-greeter`). Every component package depends on `argvus`, so no install order is
required. `argvus-game-snake` is optional and independent.

Do not casually alter packaging structure.

For Rust projects based on `skeleton-pkg-rust`:

- preserve skeleton conventions;
- preserve Makefile behavior unless explicitly asked to change it;
- avoid unnecessary recompilation;
- validate PKGBUILD and package output.

For Arch-only packaging projects based on `skeleton-pkg`, preserve that structure.

## Temporary and test files

Never create temporary, scratch, debug, or throwaway files inside any project or in
the workspace root. This includes:

- ad-hoc test or experiment scripts;
- debug scripts and one-off helpers;
- temporary outputs, logs, dumps, and fixtures.

Create these in `/tmp/argvus/` instead, and remove what you created when the task is done.

If a script is genuinely useful to the project, do not leave it in the project root.
Propose adding it to the project's proper location (for example `tests/` or
`scripts/`) and wait for approval.

Real project tests (for example `#[test]` in Rust or the project's `tests/`
directory) follow the project's normal structure and are not affected by this rule.

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
- `argvus i18n validate`
- `git diff --check`

Do not run irrelevant expensive validation across all repositories by default.

Validate affected repositories and direct consumers.

When a task modifies `de/` and requires documentation synchronization, also validate
the affected documentation in each modified project's `docs/` folder.

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

## Consolidated Rust workspace

The Rust commands of the desktop live in one Cargo workspace at `de/argvus`
(`crates/<package>`). The public entry point is `argvus <command>`, served by
`crates/argvus-cli`.

- In-process commands (library `run_command`, no separate executable): `config`,
  `i18n`, `keys` (and `gpg`), `projects`, `terminal`, `system-monitor`, `network`
  (and `bluetooth`), `widget-telemetry block|toggle`, `tui-terminal`, `setup`.
- GTK 4 helpers, installed by `argvus-gtk` in `/usr/lib/argvus/commands`:
  `control-center`, `taskbar-calendar`, `removable-devices`. The loading overlay
  stays at `/usr/lib/argvus/loading-theme/splash`.
- Retired repositories were moved to `de/retiree` and must not be modified:
  `argvus-config`, `argvus-i18n`, `argvus-keys`, `argvus-projects`, `argvus-terminal`,
  `argvus-system-monitor`, `argvus-network`, `argvus-widget-telemetry`, `argvus-tui`,
  `argvus-control-center`, `argvus-taskbar-calendar`, `argvus-removable-devices`,
  `argvus-loading-theme`, `argvus-themes`.
- `argvus-greeter` is a separate binary inside the workspace (`de/argvus/greeter`, its own
  Cargo workspace, package `argvus-greeter`). It runs before login.
- Repositories that keep their own executables: `argvus-accounts` (runs as root through
  `pkexec`), `argvus-firewall`.
- Do not add a new `/usr/lib/argvus/commands/argvus-*` path in callers; use
  `argvus <command>`. Keep callers that must start before PATH is set (systemd
  units) on `/usr/bin/argvus <command>`.

The skill `argvus-monorepo` holds the full map (crates, dispatch model, retired-repository
table). Load it for any Rust change under `de/argvus` or any reference to a retired name.

Documentation of the consolidated components is kept in `de/argvus/docs/`:
user pages under `docs/{en,pt-br}/components/<repository>/`, developer notes under
`docs/internal/<repository>/`. Do not create a `docs/` folder in a retired
repository; change the page in the workspace instead.
