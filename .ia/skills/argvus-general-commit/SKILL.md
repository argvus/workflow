---
name: argvus-general-commit
description: Commit to all ARGVUS projects.
---

# ARGVUS General Commit Workflow

Use this skill to general commit:

- Make professional conventional commits (in English) with descriptions for ALL projects in `de/` that require commits. Analyze the changes made to the project and write the commit description based on those changes. For example:

```sh
feat: new implementation for X

- A new implementation was carried out for X...
```

NOTE: Do not modify files; only make commits.

- List the "committed" projects.

RULE: Never add `Co-Authored-By:` (or any other attribution/trailer line, such as
`Signed-off-by:` or "Generated with ...") to commit messages. The message must contain
only the Conventional Commit subject and description.
