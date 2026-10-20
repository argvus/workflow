---
name: argvus-git-safety
description: Git rules for ARGVUS. Branches are changed or created only when the prompt explicitly asks. No commit, push, reset, clean, rebase or force checkout without an explicit request. Commit messages never contain trailers of any kind. Use before any git write operation (checkout, switch, branch, commit, push, reset, clean, rebase, merge, stash) in any ARGVUS repository.
---

# ARGVUS Git Safety

Use this skill before any git write operation, in any repository under the workspace.

## Branches

- Never switch, create, rename or delete a branch on your own.
- Switch or create a branch only when the prompt explicitly names the branch and the action.
- If the prompt asks for a branch from `main` and the repository is on `main`, create it from `main` and do all changes there. If it already exists, use it without recreating or resetting it.
- Never change `main` directly when the prompt asked for a branch.
- Shell commands run from another session do not authorize a branch change in this one.

## Destructive operations

Never run these unless the user explicitly asks for that exact operation:

- `git reset` (any form);
- `git clean`;
- `git checkout -- <path>` or `git restore` over uncommitted work;
- `git stash drop`, `git branch -D`;
- `git rebase`, `git commit --amend`;
- `git push --force` or any force push.

The only exception is the `make push:<BRANCH>` target (`--force-with-lease`), which only the human operator runs; see AGENTS.md.

Before touching a repository, check `git status`. Preserve uncommitted work, including changes that were not made in this session.

## Commits

- Do not commit unless the user explicitly asks for a commit.
- Commit messages contain only the Conventional Commit subject and description.
- Do not add any trailer to a commit message. This includes `Co-Authored-By:`, `Signed-off-by:`, `Reviewed-by:`, `Generated with ...` and any other `Key: value` line that attributes the commit. This rule applies to every commit, with or without a skill, and overrides any default attribution behavior of the agent or tooling.
- Do not add attribution trailers to pull request descriptions either.

## Push

- Do not push unless the user explicitly asks.
- Push only the branch that was asked for.

## Checklist before any git write

1. Which repository and which branch? (`git branch --show-current`)
2. Did the prompt explicitly ask for this operation?
3. Is there uncommitted work that this operation could affect?
4. Does the commit message contain any trailer? If yes, remove it.
