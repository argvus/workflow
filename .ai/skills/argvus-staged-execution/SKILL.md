---
name: argvus-staged-execution
description: Executes multi-stage ARGVUS refactors and migrations in stages, with stop points, approval gates and a report after each stage. Use when a task has several stages or phases ("etapas", "fases"), when a stage needs approval (Control Center screen migration, packaging or skeleton changes, deleting shared scripts), or when a prompt says to validate before continuing.
---

# ARGVUS Staged Execution

A large change is delivered as a sequence of independent stages. Each stage must be complete, validated and reported before the next one starts.

## Rules

1. Execute the stages in the order written. Do not start stage N+1 before stage N passes its acceptance check.
2. If a validation of a stage fails, stop. Report the failure with its output. Do not continue to the next stage and do not hide the failure.
3. Do not describe planned work as completed. Each report states what was done, validated and not done.
4. Keep stages small. Migrate one script or one screen per change, not several.

## Approval gates

Stop and ask for approval before:

- migrating any Control Center screen in `de/argvus/crates/argvus-control-center*` (show the plan first, as required by `AGENTS.md`);
- changing a skeleton packaging structure, the Makefile or the PKGBUILD of a skeleton project;
- centralizing shared packaging files across repositories;
- deleting a script that other repositories still call and that was not in the approved list;
- any `git` write operation not explicitly requested (see `argvus-git-safety`).

Ask with a concrete question and the options. Do not ask about things that are already decided in the prompt.

## Per-stage report

At the end of each stage, report:

- stage name and goal;
- repositories analyzed and modified;
- files changed;
- validation run, with results;
- documentation updated, created or intentionally left unchanged (with the reason);
- what is blocked or still open, and what the next stage needs.

## Starting a session in the middle of a plan

- Read the plan file or the prompt first.
- Check the current state of each repository (`git status`, the branch the prompt asks for). Do not assume the previous stage was completed.
- Resume from the first stage whose acceptance check does not pass.
