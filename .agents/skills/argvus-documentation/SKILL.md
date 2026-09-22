---
name: argvus-documentation
description: Analyze ARGVUS source repositories and audit, create, or update the Astro/Starlight documentation so it accurately reflects the current implementation.
---

# ARGVUS Documentation Workflow

Use this skill whenever documentation for the ARGVUS desktop environment must
be audited, created, reorganized, or updated.

## Inputs

Source repositories:

`de/*`

Documentation website:

`web/site-src/`

## Automatic documentation follow-up

This skill may be invoked as a follow-up to any implementation task under `de/`.

When another ARGVUS skill changes behavior under `de/`, inspect the change and
update the corresponding documentation under `web/site-src/` before the overall
task is considered complete.

The documentation update should describe the final implementation, not the original
task specification.

Do not copy implementation diffs directly into documentation.

Translate the change into:

- user behavior;
- configuration;
- commands;
- paths;
- architecture;
- troubleshooting;

as appropriate.

## Phase 1 — Documentation architecture

Inspect the existing documentation website before changing anything.

Determine:

- existing content hierarchy;
- Astro/Starlight configuration;
- sidebar/navigation organization;
- content collections;
- reusable components;
- documentation conventions;
- existing categories;
- duplicated or obsolete sections.

Build a mental model of the existing documentation before proposing changes.

## Phase 2 — Repository inventory

Inventory the repositories under `de/`.

For each relevant repository identify:

- project purpose;
- implementation language;
- binaries;
- installed services;
- package name;
- public interfaces;
- configuration;
- integration points;
- user-visible features.

Do not attempt to read every source file sequentially.

Use repository structure, manifests, search, and dependency relationships to locate
the relevant implementation.

## Phase 3 — Feature mapping

Do not assume that one documentation page equals one repository.

Map user-facing features to all repositories involved.

For example:

Control Center feature
→ argvus-control-center
→ argvus-i18n
→ argvus-hyprland
→ argvus-session
→ another provider if applicable.

Document the feature as an ARGVUS capability rather than merely describing source
repositories.

## Phase 4 — Existing documentation audit

Compare the implementation with `web/site-src/`.

Classify documentation findings as:

- accurate;
- incomplete;
- outdated;
- duplicated;
- misplaced;
- undocumented;
- unverifiable.

Identify:

- undocumented features;
- outdated commands;
- obsolete paths;
- stale screenshots/references;
- outdated architecture;
- missing cross-links;
- structural/navigation issues.

## Phase 5 — Plan

Before large edits, produce a concrete documentation plan containing:

- pages to retain;
- pages to update;
- pages to create;
- pages to merge;
- pages to remove;
- navigation changes;
- reason for each change.

Do not make speculative changes.

## Phase 6 — Implementation

When instructed to implement:

- modify only documentation/site files unless otherwise requested;
- follow existing Starlight conventions;
- preserve good existing documentation;
- replace stale information with verified information;
- prefer feature-oriented documentation;
- use code blocks only where they improve understanding;
- add relevant cross-links;
- keep terminology consistent throughout the site.

## Phase 7 — Verification

After edits:

- search documentation for stale project names;
- search for obsolete commands and paths discovered during audit;
- check internal links;
- run project validation;
- run the site build.

Fix errors caused by the documentation changes.

## Important rule

Source code wins over documentation.

If source code and existing documentation disagree, verify the implementation and
update the documentation accordingly.

Do not modify implementation to match stale documentation.

## Documentation impact classification

For every implementation change, classify documentation impact as one of:

- required;
- recommended;
- none.

`required` examples:

- new or changed user-facing functionality;
- changed command/path/configuration;
- changed installation/runtime behavior;
- changed architecture contract relevant to contributors.

`recommended` examples:

- meaningful internal architecture change useful for developer documentation.

`none` examples:

- refactor with identical behavior;
- formatting;
- test-only changes;
- internal cleanup with no documentation-visible effect.

When impact is `required`, update the site during the same task.