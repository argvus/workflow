---
name: argvus-i18n
description: Internationalization workflow for ARGVUS using argvus-i18n across Rust, Shell, QML, and shared catalogs.
---

# ARGVUS i18n Workflow

Use this skill whenever visible strings or locale behavior changes.

## Central system

Use `argvus-i18n`.

Do not create local translation systems in individual projects.

## Supported catalogs

At minimum:

- en-US
- pt-BR

en-US is the canonical fallback.

## Fallback

Expected behavior:

selected locale
→ en-US
→ key.

Known application strings must not fall through to raw keys in a correct install.

## Domains

Use the existing domain for the application.

Do not duplicate application prefixes unnecessarily when the domain already scopes
the keys.

Follow current naming conventions.

## Keys

Prefer semantic keys.

Avoid keys based on exact English copy.

Good:

`input.hardware.polling_rate`

Bad:

`label_42`

## Placeholders

Keep placeholders identical across locales.

Validate interpolation types and names.

## Rust

Use the shared Rust API/crate.

Do not create ad-hoc JSON parsing inside each Rust app.

## Shell

Use the provided shell helper when the project already supports it.

## QML

Use the shared QML/singleton integration.

Do not maintain separate QML-only dictionaries.

## Installed catalog validation

Do not validate only source JSON.

When packaging changes, verify staged/installed catalogs under the actual runtime path.

A source catalog being correct does not guarantee the installed package is current.

## Adding strings

For new visible strings:

1. identify domain;
2. add en-US;
3. add pt-BR;
4. validate placeholders;
5. update runtime lookup;
6. test real render.

## Validation

Use:

`argvus-i18n validate`

and repository-specific tests.

If package contents changed, validate packaging/staged install.

## Final report

Report:

- domain;
- keys added/changed;
- fallback tested;
- installed catalog tested;
- raw-key checks.