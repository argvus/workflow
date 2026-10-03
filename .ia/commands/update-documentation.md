---
description: Analyze all ARGVUS projects and update each project's docs/ folder
---

Analyze all existing projects in `de/` and update the documentation of each project, located in that project's own `docs/` folder (for example `de/argvus-hyprland/docs/`).

Follow these rules:

1. First, list and identify all projects existing in `de/`.
2. Analyze each project individually.
3. Read the relevant files for each project to understand:

- the project's purpose;
- existing features;
- commands and usage;
- configurations;
- relevant dependencies;
- the project's current state;
- information that is already documented.

4. Next, analyze the current structure of each project's `docs/` folder to understand:

- how the documentation is organized;
- which pages exist;
- the format and writing style used;
- where each feature should be documented within the project's `docs/`.

5. Compare the existing documentation with the actual state of the projects in `de/`.
6. Update each project's `docs/` folder to:
- add documentation for projects or features that are not yet documented (creating `docs/` if a project has none);
- correct outdated information;
- update features that have changed;
- remove information that no longer matches the code;
- maintain consistency across pages;
- preserve the existing style and structure of the docs.
7. Do not invent features, commands, configurations, or information that are not present in the projects.
8. Do not alter the source code of the projects within `de/`. The only permitted changes are inside each project's `docs/` folder. Do not write project documentation to `web/argvus-website`.
9. Avoid unnecessary changes to the documentation. Preserve correct content that already exists.
10. If there is conflicting information or something that cannot be determined from the project code/documentation, do not make assumptions. Investigate the available files; if it is still impossible to determine the facts, preserve the existing information and note the uncertainty.
11. Upon completion:
- list the projects that were analyzed;
- show which files in each project's `docs/` were created or modified;
- summarize the key updates made;
- check the final diff to ensure no changes were made outside the `docs/` folders.

Important:

The source of truth for the documentation must be the current state of the projects in `de/`.

Do not provide a superficial summary of the projects. Analyze the code and existing documentation before modifying the site.
