---
name: argvus-theme-creation
description: End-to-end workflow for creating or adding official ARGVUS themes. Use whenever a task
  creates a new ARGVUS theme, adds a new official theme ID, adds or changes its wallpaper,
  palette, preview, Light/Dark metadata, or otherwise introduces a new theme into ARGVUS.
  Theme creation is not complete until the desktop implementation, ARGVUS landing page,
  and documentation are synchronized.
---


# ARGVUS Theme Creation

Use this skill whenever creating or adding a new official ARGVUS theme.

Examples:

- `argvus-dark-monokai`
- `argvus-light-gruvbox`
- `argvus-dark-hackerman`
- `argvus-solitude`
- `argvus-onelight`
- any future official ARGVUS theme

This skill is specifically for **theme creation / introduction**.

For ordinary appearance changes that do not create a new theme, use the normal
appearance/development/documentation skills instead.

---

# Definition of done

A new ARGVUS theme is NOT complete when only the desktop theme files are added.

A new official theme is complete only when all applicable layers are synchronized:

```text
theme implementation under de/
        ↓
theme registration / runtime integration
        ↓
wallpaper / visual assets
        ↓
ARGVUS landing page
        ↓
ARGVUS documentation
        ↓
validation
```

The implementation under `de/` remains the source of truth.

The website and documentation must describe the final implementation, not the
initial request or an assumed design.

---

# Mandatory companion skills

This skill does not replace the domain skills.

Load and follow the relevant skills in addition to this one.

For theme creation, normally use:

- `.agents/skills/argvus-development/SKILL.md`
- `.agents/skills/argvus-theme-creation/SKILL.md`
- `.agents/skills/argvus-web/SKILL.md`
- `.agents/skills/argvus-documentation/SKILL.md`

Also use when applicable:

- `.agents/skills/argvus-rust-code/SKILL.md`
- `.agents/skills/argvus-ui/SKILL.md`
- `.agents/skills/argvus-i18n/SKILL.md`
- `.agents/skills/argvus-session-integration/SKILL.md`
- `.agents/skills/argvus-rust-packaging/SKILL.md`
- `.agents/skills/argvus-hyprland/SKILL.md`

If a repository touched by the task contains Rust, `argvus-rust-code` is mandatory.

---

# Workspace

Workspace root:

`/home/boss/Projects/github/organizations/argvus`

Desktop projects:

`/home/boss/Projects/github/organizations/argvus/de/`

Web projects:

`/home/boss/Projects/github/organizations/argvus/web/`

Documentation site:

`/home/boss/Projects/github/organizations/argvus/web/site-src/`

---

# 1. Audit before implementation

Before modifying files, audit the current theme architecture.

Do not assume the architecture from a previous theme implementation.

Inspect the current source code and determine:

1. the source of truth for official themes;
2. how official theme IDs and display names are registered;
3. how Light/Dark metadata is represented;
4. how palettes are represented;
5. how semantic tokens are mapped;
6. how Highlight/Accent overrides work;
7. how wallpapers are associated;
8. how previews are generated/rendered;
9. how theme state is persisted;
10. which generated files are produced;
11. which runtime components consume theme state;
12. how runtime apply/reload works;
13. how themes are projected to greeter/login;
14. how themes are projected to taskbar;
15. how themes are projected to control panel;
16. how themes are projected to widget telemetry;
17. how themes are projected to notifications;
18. how themes are projected to launcher;
19. how themes are projected to terminal;
20. how theme assets are packaged.

Audit every relevant repository under `de/`.

Do not stop after finding `argvus-appearance`.

A theme may cross several repositories.

---

# 2. Theme source of truth

Prefer the existing ARGVUS architecture:

```text
single theme source of truth
        ↓
generated / projected state
        ↓
runtime consumers
```

Do not independently hardcode the same palette into multiple runtime projects
unless the current architecture explicitly requires it.

Do not create theme-specific scripts such as:

```text
apply-<theme>.sh
<theme>-special-case.rs
<theme>_override.qml
```

unless the current architecture genuinely requires them and there is no generic
mechanism available.

Prefer data-driven theme definitions.

---

# 3. Theme metadata

For each new theme, confirm and preserve:

- display name;
- stable theme ID;
- Light/Dark mode;
- palette source;
- default Highlight/Accent Color;
- wallpaper ID/path;
- preview data;
- package ownership;
- any attribution/licensing requirements.

Theme IDs are stable API-like identifiers.

Do not silently rename a theme ID after implementation.

If the requested theme is based on an external palette, preserve the original
palette values as the source colors and clearly distinguish any ARGVUS-specific
derived semantic colors.

---

# 4. External palette rules

When a theme is based on an external theme/palette:

1. use the original project's official source whenever possible;
2. verify the actual color values before implementation;
3. do not substitute a third-party port if the canonical source exists;
4. distinguish official source colors from ARGVUS-derived UI tokens;
5. do not present derived colors as official upstream colors;
6. preserve attribution or license requirements when applicable;
7. do not copy proprietary icons/assets unless their license explicitly permits it.

Examples of acceptable derivation:

```text
official background
official foreground
official accent
        ↓
ARGVUS semantic surface/border/hover tokens
```

The derived tokens must visually remain faithful to the upstream palette.

---

# 5. Wallpaper integration

For a new theme, inspect `argvus-wallpapers`.

If the wallpaper already exists:

- use the real filename;
- use the real installed path;
- do not duplicate it into another project;
- verify that packaging installs it.

If the wallpaper does not exist and the task includes creating one, ensure the final
theme references the asset through the existing wallpaper pipeline.

Never invent the installed path without checking packaging.

Verify, when applicable:

- `PKGBUILD`;
- Makefile;
- install scripts;
- manifests;
- package ownership.

---

# 6. Control Center integration

A new official theme must be discoverable through the current Appearance/Themes UI.

Verify:

- official theme list;
- display name;
- stable ID;
- Light/Dark category;
- preview;
- wallpaper association;
- selection;
- Apply behavior;
- persistence;
- reopening the Control Center;
- default Highlight/Accent;
- custom Highlight/Accent override;
- i18n.

Do not add new hardcoded user-visible strings when the component uses `argvus-i18n`.

---

# 7. Runtime consumers

Audit and validate every current consumer discovered in the source tree.

Common consumers include:

- `argvus-control-center`;
- `argvus-control-panel`;
- `argvus-taskbar`;
- `argvus-widget-telemetry`;
- `argvus-launcher`;
- `argvus-notifications`;
- `argvus-terminal`;
- `argvus-lock`;
- `argvus-greeter`;
- `argvus-session`;
- `argvus-hyprland`;
- splash/theme-splash;
- other UI components discovered during the audit.

Do not assume this list is exhaustive.

A successful implementation must not leave the desktop partly on the old theme.

---

# 8. Landing page synchronization

Every newly created official ARGVUS theme must be evaluated for presentation on
the ARGVUS landing page.

The landing page update is part of the same task.

Search the current web source under:

`/home/boss/Projects/github/organizations/argvus/web/`

Identify the actual landing page implementation from the current source.

Do not assume a specific filename or framework entry point.

Update the landing page when the current site exposes or showcases:

- themes;
- screenshots;
- customization;
- appearance;
- feature highlights;
- theme galleries;
- visual assets.

At minimum, for a theme gallery/list that already exists:

- add the new theme;
- use the correct display name;
- use the stable theme ID where applicable;
- use the correct Light/Dark classification;
- use the real wallpaper/preview asset or the site's established preview mechanism;
- preserve the current ordering/grouping convention;
- preserve responsive behavior;
- preserve accessibility/alt text conventions;
- preserve visual consistency with existing cards/items.

Do not redesign unrelated landing-page sections just to add one theme.

If the landing page intentionally does not enumerate themes, do not force a new
theme gallery. Instead, document why no landing-page file needed modification.

---

# 9. Documentation synchronization

Every new official ARGVUS theme must be reflected in the documentation under:

`/home/boss/Projects/github/organizations/argvus/web/site-src/`

Find the current theme/appearance documentation from the source tree.

Do not assume page names from memory.

Update the appropriate documentation so users can understand:

- the new theme display name;
- theme ID;
- Light/Dark mode;
- where it appears in Control Center;
- how to select/apply it;
- wallpaper integration when relevant;
- default Highlight/Accent Color when relevant;
- any upstream palette attribution when relevant;
- any special behavior or limitations.

If the docs maintain a table/list/gallery of official themes, update it.

If the docs maintain theme screenshots/previews, update those according to the
existing documentation pattern.

Update navigation/cross-links only when the current information architecture
requires it.

Do not create duplicate documentation pages when an existing themes page is the
correct location.

---

# 10. Landing page vs documentation

Treat these as separate deliverables.

Landing page purpose:

- showcase;
- visual discovery;
- product presentation;
- concise feature communication.

Documentation purpose:

- accurate usage information;
- configuration;
- behavior;
- IDs/paths;
- troubleshooting;
- technical/user reference.

Do not replace documentation with marketing copy.

Do not overload the landing page with implementation details.

---

# 11. Asset handling for web/docs

Before copying any wallpaper or preview into `web/`:

1. inspect the current site's asset strategy;
2. determine whether it references installed/project assets, copies optimized web
   assets, or has its own image pipeline;
3. follow the existing convention.

Do not duplicate large wallpapers unnecessarily.

If the site requires optimized derivatives, generate them according to the site's
existing tooling/conventions.

Do not modify the original wallpaper merely to satisfy web optimization.

---

# 12. Validation

Validate only affected repositories and direct consumers unless the task genuinely
requires broader validation.

Desktop validation may include, where applicable:

```bash
cargo fmt --all -- --check
cargo check --workspace
cargo clippy
cargo test
make validate
make build
makepkg --printsrcinfo
luac -p
sh -n
shellcheck
qmllint
argvus-i18n validate
git diff --check
```

Validate the website using the commands defined by its current package/project
configuration.

Validate documentation under `web/site-src/` using its actual Astro/Starlight
commands.

Do not guess package-manager commands. Inspect the current project first.

If full visual verification requires a running Hyprland session or real logout/login,
report that as manual validation.

---

# 13. Git safety

Never:

- reset unrelated changes;
- clean untracked files;
- overwrite unrelated work;
- force checkout;
- rewrite history;
- force push.

Do not commit or push unless explicitly instructed.

The workspace may contain uncommitted work across multiple repositories.

---

# 14. Final report

At the end of a theme-creation task, report:

## Theme

- display name;
- stable ID;
- mode;
- upstream palette/source;
- default accent;
- wallpaper;
- any derived semantic colors.

## Desktop

- repositories analyzed;
- repositories modified;
- source of truth;
- runtime consumers updated;
- generated files;
- apply/reload path;
- i18n changes;
- packaging changes.

## Landing page

- files/pages modified;
- how the new theme is presented;
- assets/previews added or reused;
- intentionally unchanged landing-page areas and why.

## Documentation

- pages updated;
- pages created, if any;
- navigation/cross-links updated;
- information added.

## Validation

- commands executed;
- successful checks;
- failed/skipped checks;
- required manual validation.

## Remaining limitations

Report only real remaining limitations.

Do not describe planned work as completed.

---

# Core rule

Whenever a task **creates a new official ARGVUS theme**, updating the desktop theme
implementation alone is incomplete.

The task must always evaluate and synchronize:

```text
de/
+
web landing page
+
web/site-src documentation
```

in the same implementation task.

Only leave the landing page or documentation unchanged when inspection proves no
update is needed, and explain that decision in the final report.

