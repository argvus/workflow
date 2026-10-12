---
name: argvus-recursive-commits
description: Create commits for ALL changes made across ALL projects, following the Conventional Commits standard. Perform this action when the user explicitly requests that the commit be made.
---

# ARGVUS Recursive Commits Workflow

Use this skill to finish:

- Create professional commits for these changes. Commit messages must follow the *Conventional Commits* format (using `feat:`, `fix:`, `chore:`, `docs:`, etc.) and include a description. For example:

```sh
feat: new implementation for X

- A new implementation was created for X...
```

RULE:

- Do not switch branches.
- Commit all changes in ALL projects within the `de/` folder that require a commit.
- IMPORTANT: Do not alter the files.
- Even if there are changes that weren't part of this session, commit them anyway.
- Never add `Co-Authored-By:` (or any other attribution/trailer line, such as `Signed-off-by:` or "Generated with ...") to commit messages. The message must contain only the Conventional Commit subject and description.
