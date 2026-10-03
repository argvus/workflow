---
description: Analyze all ARGVUS projects and update the website documentation
---

Analyze all existing projects in `de/` and update the ARGVUS website documentation located in `web/argvus-website`.

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

4. Next, analyze the current structure of `web/argvus-website` to understand:

- how the documentation is organized;
- which pages exist;
- the format and writing style used;
- where each project should be documented.

5. Compare the existing documentation with the actual state of the projects in `de/`.
6. Update `web/argvus-website` to:
- add documentation for projects that are not yet documented;
- correct outdated information;
- update features that have changed;
- remove information that no longer matches the code;
- maintain consistency across pages;
- preserve the site's existing style and structure.
7. Do not invent features, commands, configurations, or information that are not present in the projects.
8. Do not alter the projects within `de/`. The task is solely to analyze these projects and update `web/argvus-website`.
9. Avoid unnecessary changes to the site. Preserve correct content that already exists.
10. If there is conflicting information or something that cannot be determined from the project code/documentation, do not make assumptions. Investigate the available files; if it is still impossible to determine the facts, preserve the existing information and note the uncertainty.
11. Upon completion:
- list the projects that were analyzed; - show which files in `web/argvus-website` were created or modified;
- summarize the key updates made;
- check the final diff to ensure no changes were made outside of `web/argvus-website`.

Important:

The source of truth for the documentation must be the current state of the projects in `de/`.

Do not provide a superficial summary of the projects. Analyze the code and existing documentation before modifying the site.
