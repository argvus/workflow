---
name: argvus-web
description: Development workflow for ARGVUS web projects under web/ (website, landing page, logo, extras). Project documentation does NOT live here; it lives in each project's docs/ folder.
---

# ARGVUS Web Workflow

Use this skill for work under:

`web/`

## Website

Primary website source:

`web/argvus-website/`

Project documentation is NOT maintained in the website anymore. Each project keeps
its own documentation in its `docs/` folder (for example
`de/argvus-hyprland/docs/`). Do not add, edit, or look for project documentation
under `web/argvus-website/`.

Inspect:

- package.json;
- framework/build config;
- pages and content;
- navigation;
- reusable components.

## Preserve existing architecture

Do not redesign the site globally for a localized task.

Follow current conventions unless there is a concrete UX or maintenance issue.

## Dependencies

Use the package manager already selected by the project.

Do not switch npm/pnpm/bun without explicit instruction.

## Build

Use the actual scripts defined by package.json.

Run:

- build;
- lint;
- typecheck;
- link validation

when available.

## Documentation interaction

When a task also requires documentation, use `argvus-documentation`. That
documentation is written in the `docs/` folder of the affected project, not in
`web/`.

## Assets

Do not invent screenshots.

Use actual assets or mark missing visuals clearly.

## Links

Prefer internal site links.

Fix broken routes introduced by changes.

When linking to project documentation, follow how the website currently references
each project's `docs/` folder; do not recreate docs pages inside the website.

## Final report

Report:

- pages/components changed;
- navigation changes;
- build result;
- warnings;
- unresolved assets/links.
