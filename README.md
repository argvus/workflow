# ARGVUS Workflow

This repository provides the central, Make-based workflow for the ARGVUS Linux desktop ecosystem. It creates a predictable local workspace for the independent ARGVUS repositories, clones projects from the configured Git provider, builds Arch Linux packages, collects the resulting artifacts, installs them on the host, creates source archives, and provides cleanup and multi-remote push helpers.

The workflow is intentionally lightweight: the repository itself contains orchestration only. Each cloned project remains an independent checkout with its own Makefile, build system, package metadata, and Git history.

After cloning this workflow repository, remove its root `.git/` directory before creating the child repositories. The `de/`, `web/`, and `misc/` directories will contain independent Git repositories, so the workflow directory should not remain a parent Git repository:

```sh
git clone <workflow-repository-url> workflow
cd workflow
rm -rf .git
```

Do not remove the `.git/` directories created inside `de/`, `web/`, or `misc/`; those belong to the individual project checkouts.

## Workspace layout

Running a clone target creates the following directories when needed:

```text
.
├── de/       # ARGVUS desktop-environment projects
├── web/      # Website and web-infrastructure projects
├── misc/     # Miscellaneous repositories
├── .tools/   # Workflow command implementation
├── builds/   # Packages collected for installation
└── zips/     # Source archives created by the zip targets
```

The desktop projects listed in `PROJECTS_DE` are the installable projects by default. A project is expected to provide a `build` target and to place its package in `build/dist/` (or in the directory configured through `PROJECTS_DE_DIST`).

`argvus` is the master package. Its PKGBUILD (`pkgbase=argvus`) produces a single package, `argvus`, which ships the CLI, the GTK helpers, the login greeter (source in `argvus/crates/argvus-greeter`) and the loading overlay. Every other component package depends on `argvus`, so no install order is required. Retired repositories are kept in `de/retiree` and are not part of `PROJECTS_DE`. `argvus-game-snake` is independent and optional.

## Requirements

The host should provide:

- GNU Make
- Git and access to the configured remote repositories
- The build dependencies required by each ARGVUS project
- Arch Linux `makepkg` tooling for package-producing projects
- `pacman` and `sudo` for installation
- `zip` for the `zip-all` and `zip` targets

The `install` target installs packages with `pacman`, so it must be run on an Arch Linux system with permission to elevate privileges.

## Quick start

Clone all configured repositories and install every desktop project:

```sh
make clone full
make install full
```

The `install` command runs the corresponding `build` and `collect` steps before installing, so a separate build or collection step is not required.

Before building, make sure the repositories have already been cloned with `make clone full` or a specific `make clone de ...` command.

## Claude compatibility

Run the following command from the workflow root to prepare the checkout for Claude:

```sh
make claude
```

This creates the `CLAUDE.md` link to `AGENTS.md`, the `.claude/skills` link to `../.ai/skills`, and the `.claude/commands` link to `../.ai/commands`. Run it after cloning this workflow repository and before using Claude in the workspace. The command is intended for the workflow root; the cloned child repositories remain independent projects.

## Codex and OpenCode compatibility

The workflow also supports Codex and OpenCode. The canonical folders are `.ai/skills/` and `.ai/commands/`. Each command prepares the workspace root for its tool with the links that tool reads:

```sh
make codex
make opencode
```

- `make codex` creates `.agents/skills` (linked to `../.ai/skills`) and `.codex/prompts` (linked to `../.ai/commands`).
- `make opencode` creates `.agents/skills` (linked to `../.ai/skills`) and `.opencode/commands` (linked to `../.ai/commands`).

Each link is checked on its own. Re-running a command completes any missing link and never overwrites a path that is not a symlink. Commands and skills are shared by all three tools from `.ai/`.

## Commands

| Command | Purpose |
| --- | --- |
| `make help` | Show the available commands and configurable variables. |
| `make claude` | Prepare the workspace for Claude: creates the `CLAUDE.md` link to `AGENTS.md`, and the `.claude/skills` and `.claude/commands` links. |
| `make codex` | Prepare the workspace for Codex: creates the `.agents/skills` and `.codex/prompts` links. |
| `make opencode` | Prepare the workspace for OpenCode: creates the `.agents/skills` and `.opencode/commands` links. |
| `make status` | Show the Git status of every cloned desktop project under `de/`. |
| `make clone full` | Clone all projects into `de/`, `web/`, and `misc/`. Existing directories are left untouched. |
| `make clone de <project> [project...]` | Clone selected desktop-environment projects into `de/`. |
| `make clone web <project> [project...]` | Clone selected web projects into `web/`. |
| `make clone misc <project> [project...]` | Clone selected miscellaneous projects into `misc/`. |
| `make build full` | Remove old package artifacts and build all projects from `de/`. |
| `make build <project> [project...]` | Build only the selected projects from `de/`. |
| `make collect` | Remove stale collected package files and copy package archives from available projects into `builds/`. |
| `make install full` | Build all projects, collect their packages, and install them with `pacman`. |
| `make install <project> [project...]` | Build, collect, and install only the selected projects. |
| `make zip-all` | Compress every project from `de/` into `zips/<project>.zip`. |
| `make zip full` | Same as `make zip-all`. |
| `make zip <project> [project...]` | Compress only the selected projects from `de/`. |
| `make clean:dist` | Remove per-project package output directories for installable desktop projects. |
| `make clean:all` | Run available `clean` targets and remove generated package output, `node_modules`, and `builds/` across all cloned project groups. |
| `make push:<branch>` | Push the selected branch of each desktop checkout to the configured `lab` and `gitea` remotes when available. Branch names may contain `/`. |
| `make checkout:<branch>` | Run `git checkout <branch>` in every desktop checkout under `de/`. The branch must already exist locally. |
| `make switch:<branch>` | Run `git switch -c <branch>` in every desktop checkout under `de/`. |
| `make requirements` | Create or recreate `.ai/skills/argvus-requirements/SKILL.md`, listing each tool in `REQUIREMENTS` with its installed version. Missing tools are listed as `not installed`. |

`collect` reports and skips projects without an output directory or package. `install` fails when no `argvus-*.pkg.tar.zst` archive is available.

## Configuration

Variables can be overridden on the command line without editing the Makefile:

| Variable | Default | Description |
| --- | --- | --- |
| `BASE_URL` | `git@gitlab:argvus` | Base Git URL used to construct clone URLs such as `$(BASE_URL)/argvus-hyprland.git`. |
| `PROJECTS_DE_DIST` | `build/dist` | Package output directory inside each desktop project. |
| `BUILD_DIR` | `builds` | Local directory used to collect packages before installation. |
| `ZIP_DIR` | `zips` | Local directory used to write project source archives. |
| `ZIP_EXCLUDES` | `.git/* target/* tmp/* build/*` | Space-separated patterns passed to `zip -x`. |
| `REMOTES_PUSH` | `lab gitea` | Git remotes used by `push:<branch>`. |
| `REQUIREMENTS` | `rust wayland hyprland hypridle vala waybar quickshell rofi` | Space-separated tools listed by `make requirements`. |
| `SKILLS_DIR` | `.ai/skills` | Skills directory that `make requirements` writes into. |

Examples:

```sh
make clone full BASE_URL=git@github.com:argvus
make clone de argvus-hyprland argvus-appearance
make clone web argvus-website packages
make build full
make build argvus-hyprland argvus-appearance
make install full
make install argvus-hyprland argvus-appearance
make collect BUILD_DIR=/tmp/argvus-builds
make install full BUILD_DIR=/tmp/argvus-builds
make zip-all
make zip-all ZIP_DIR=/tmp/argvus-zips
make requirements
make requirements REQUIREMENTS='rust hyprland'
```

## Source archives

`zip-all` iterates over `PROJECTS_DE`, changes into each project directory under `de/`, and writes `zips/<project>.zip` next to the Makefile. `zip full` is an alias, and `zip <project>...` restricts the run to specific projects.

Each archive is recreated from scratch, so a failed or partial archive is never left behind. Projects without a directory under `de/` are reported on stderr and skipped, and a failure in one project does not stop the remaining ones. A project name outside `PROJECTS_DE` is a hard error.

Paths matching `ZIP_EXCLUDES` are dropped from the archive, including nested content: `.git/*`, `target/*`, `tmp/*`, and `build/*` are all removed recursively, so `build/dist/*.pkg.tar.zst` packages never end up in a source archive. The patterns are literal and are not subject to shell pathname expansion.

## Package handling

For each available installable project, `collect` copies files matching:

```text
*.pkg.tar.zst
```

An adjacent `.sig` file is copied when present. Previously collected package and signature files are removed before collection, avoiding stale packages from older builds. `install` builds and collects the requested scope before passing only its package archives to `pacman`; signature files are not included in the installation argument list.

## Git behavior

Clone targets skip any project directory that already exists. They do not fetch, reset, or modify an existing checkout. The push helper operates only on desktop projects, skips repositories without the requested local branch or configured remote, and stops if an actual push fails.

`checkout:<branch>` and `switch:<branch>` iterate over `PROJECTS_DE` and run the requested Git command in every project that is a Git checkout, reporting the ones that are not. A failure in one project does not stop the others, and the command exits non-zero if any project failed. Neither target uses a forced checkout, so Git refuses to switch when local modifications would be lost; no uncommitted work is discarded. `switch:<branch>` additionally fails in any project where the branch already exists, because `git switch -c` does not reuse an existing branch.

These targets are dispatched by name, not by Make pattern rules. A Make target cannot contain `:`, and Make splits a goal on `/` before matching it against a pattern, so both `make push:main` and `make push:feature/name` are handled by the Makefile's `.DEFAULT` rule. Goals outside `push`, `checkout`, and `switch` still fail with the standard unknown-target error.

## Scope and ownership

This repository owns the cross-project workflow and directory layout. The Makefile is a thin command entry point; the implementation lives in `.tools/main.sh`. Individual ARGVUS repositories own their source code, package versions, dependencies, and project-specific build and clean implementations. When those contracts change, update the workflow script or project Makefiles together.
