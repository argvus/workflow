---
name: argvus-general-commit
description: Commit to all ARGVUS projects.
disable-model-invocation: true
---

User-invoked only. Agents must not load or follow this skill on their own.

# ARGVUS General Commit Workflow

Use this skill to general commit:

- Make professional conventional commits (in English) with descriptions for ALL projects in `de/` that require commits. Analyze the changes made to the project and write the commit description based on those changes. For example:

```sh
feat: new implementation for X

- A new implementation was carried out for X...
```

NOTE: Do not modify files; only make commits.

- List the "committed" projects.

RULE: Do not add any trailer to commit messages: no `Co-Authored-By:`, `Signed-off-by:`,
`Reviewed-by:`, "Generated with ..." or any other `Key: value` attribution line. The message
must contain only the Conventional Commit subject and description.
