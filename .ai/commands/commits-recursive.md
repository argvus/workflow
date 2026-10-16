---
description: Create commits for ALL changes made across ALL projects, following the Conventional Commits standard. Perform this action when the user explicitly requests that the commit be made.
disable-model-invocation: true
---

User-invoked only. Agents must not load or follow this command on their own.

# ARGVUS Recursive Commits

- Create professional commits for these changes. Commit messages must follow the *Conventional Commits* format (using `feat:`, `fix:`, `chore:`, `docs:`, etc.) and include a description. For example:

```sh
feat: new implementation for X

- A new implementation was created for X...
```

RULE:

- Do not switch or create branches on your own. Switch or create a branch only when the prompt explicitly asks for it.
- Commit all changes in ALL projects within the `de/` folder that require a commit.
- IMPORTANT: Do not alter the files.
- Even if there are changes that weren't part of this session, commit them anyway.
- Do not add any trailer to commit messages: no `Co-Authored-By:`, `Signed-off-by:`, `Reviewed-by:`, "Generated with ..." or any other `Key: value` attribution line. The message must contain only the Conventional Commit subject and description.
