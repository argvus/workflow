---
name: argvus-update-documentation
description: Final step that updates the documentation for the modified projects when needed. Use when the user asks to finish by updating documentation.
---

# ARGVUS Update Documentation Workflow

Use this skill to finish:

- Update or implement the changes in the documentation (if necessary).

Only for the modified projects, and only those that already have a `docs/` folder.
If a modified project has no `docs/`, do NOT create it and do NOT create documentation; just report it.

Documentation lives in each project's own `docs/` folder (for example
`de/argvus-hyprland/docs/`). Update only the `docs/` of the projects that were
modified. Do not use `web/argvus-website/` for project documentation.
