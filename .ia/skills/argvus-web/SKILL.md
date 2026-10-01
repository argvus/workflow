---
name: argvus-web
description: Development workflow for ARGVUS web projects, including Astro/Starlight documentation site under web/site-src.
---

# ARGVUS Web Workflow

Use this skill for work under:

`web/`

## Documentation site

Primary docs source:

`web/site-src/`

Inspect:

- package.json;
- Astro config;
- Starlight config;
- content collections;
- navigation;
- reusable components.

## Preserve existing architecture

Do not redesign the site globally for a localized documentation task.

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

When content accuracy depends on ARGVUS implementation, also use:

`argvus-documentation`.

## Assets

Do not invent screenshots.

Use actual assets or mark missing visuals clearly.

## Links

Prefer internal site links for ARGVUS docs.

Fix broken routes introduced by changes.

## Final report

Report:

- pages/components changed;
- navigation changes;
- build result;
- warnings;
- unresolved assets/links.