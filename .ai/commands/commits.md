---
description: Analyze git changes and create a commit
disable-model-invocation: true
---

User-invoked only. Agents must not load or follow this command on their own.

Target repository: `de/$ARGUMENTS`

Use this directory as the working directory for all Git commands.

Before doing anything else:

1. Verify that `de/$ARGUMENTS` exists.
2. Verify that it is a Git repository.
3. Do not operate on the parent repository.
4. Do not undo changes.
5. Do not leave the current branch.

Review the current git changes.

Run:

- git status
- git diff
- git diff --cached

Analyze only the changes that actually exist.

Do not modify source files.

Determine whether the changes represent one coherent change.

If yes:

1. Create a concise commit message.
2. Stage the appropriate files.
3. Review the staged diff.
4. Create the commit (Always use the current branch).

If there are unrelated changes, do not commit them together.
Explain how they should be separated first.

Never invent changes that are not present in git diff.

Do not add any trailer to the commit message: no `Co-Authored-By:`, `Signed-off-by:`, `Reviewed-by:`, "Generated with ..." or any other `Key: value` attribution line.
