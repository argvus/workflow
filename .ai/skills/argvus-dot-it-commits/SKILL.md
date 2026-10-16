---
name: argvus-dot-it-commits
description: Create the commits for the changes made, using Conventional Commits. Use when the user explicitly asks to commit.
disable-model-invocation: true
---

User-invoked only. Agents must not load or follow this skill on their own.

# ARGVUS Dot It Commits Workflow

Use this skill to finish:

- Create professional commits for these changes. Commit messages must follow the *Conventional Commits* format (using `feat:`, `fix:`, `chore:`, `docs:`, etc.) and include a description. For example:

```sh
feat: new implementation for X

- A new implementation was created for X...
```

RULE:

- Do not switch or create branches on your own. Switch or create a branch only when the prompt explicitly asks for it.
- IMPORTANT: Do not alter the files.
- Even if there are changes that weren't part of this session, commit them anyway.
- Do not add any trailer to commit messages: no `Co-Authored-By:`, `Signed-off-by:`, `Reviewed-by:`, "Generated with ..." or any other `Key: value` attribution line. The message must contain only the Conventional Commit subject and description.
