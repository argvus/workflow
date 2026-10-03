---
name: argvus-do-it-commits
description: Commit the changes.
---

# ARGVUS Do it commits Workflow

Use this skill to finish:

- Create professional commits for these changes. Commit messages must follow the *Conventional Commits* format (using `feat:`, `fix:`, `chore:`, `docs:`, etc.) and include a description. For example:

```sh
feat: new implementation for X

- A new implementation was created for X...
```

RULE: Never add `Co-Authored-By:` (or any other attribution/trailer line, such as
`Signed-off-by:` or "Generated with ...") to commit messages. The message must contain
only the Conventional Commit subject and description.
