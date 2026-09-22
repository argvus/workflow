# ARGVUS Workflow

This repository provides the central, Make-based workflow for the ARGVUS Linux desktop ecosystem. It creates a predictable local workspace for the independent ARGVUS repositories, clones projects from the configured Git provider, builds Arch Linux packages, collects the resulting artifacts, installs them on the host, and provides cleanup and multi-remote push helpers.

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
└── builds/   # Packages collected for installation
```

The desktop projects listed in `PROJECTS_DE` are the installable projects by default. A project is expected to provide a `build` target and to place its package in `build/dist/` (or in the directory configured through `PROJECTS_DE_DIST`).

## Requirements

The host should provide:

- GNU Make
- Git and access to the configured remote repositories
- The build dependencies required by each ARGVUS project
- Arch Linux `makepkg` tooling for package-producing projects
- `pacman` and `sudo` for installation

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

This creates the `CLAUDE.md` link to `AGENTS.md` and the `.claude/skills` link to `.agents/skills`. Run it after cloning this workflow repository and before using Claude in the workspace. The command is intended for the workflow root; the cloned child repositories remain independent projects.

## Commands

| Command | Purpose |
| --- | --- |
| `make help` | Show the available commands and configurable variables. |
| `make claude` | Prepare the workflow checkout for Claude by creating the `CLAUDE.md` and `.claude/skills` links. |
| `make clone full` | Clone all projects into `de/`, `web/`, and `misc/`. Existing directories are left untouched. |
| `make clone de <project> [project...]` | Clone selected desktop-environment projects into `de/`. |
| `make clone web <project> [project...]` | Clone selected web projects into `web/`. |
| `make clone misc <project> [project...]` | Clone selected miscellaneous projects into `misc/`. |
| `make build full` | Remove old package artifacts and build all projects from `de/`. |
| `make build <project> [project...]` | Build only the selected projects from `de/`. |
| `make collect` | Remove stale collected package files and copy package archives from available projects into `builds/`. |
| `make install full` | Build all projects, collect their packages, and install them with `pacman`. |
| `make install <project> [project...]` | Build, collect, and install only the selected projects. |
| `make clean:dist` | Remove per-project package output directories for installable desktop projects. |
| `make clean:all` | Run available `clean` targets and remove generated package output, `node_modules`, and `builds/` across all cloned project groups. |
| `make push:<branch>` | Push the selected branch of each desktop checkout to the configured `lab` and `gitea` remotes when available. |

`collect` reports and skips projects without an output directory or package. `install` fails when no `argvus-*.pkg.tar.zst` archive is available.

## Configuration

Variables can be overridden on the command line without editing the Makefile:

| Variable | Default | Description |
| --- | --- | --- |
| `BASE_URL` | `git@gitlab:argvus` | Base Git URL used to construct clone URLs such as `$(BASE_URL)/argvus-shell.git`. |
| `PROJECTS_DE_DIST` | `build/dist` | Package output directory inside each desktop project. |
| `BUILD_DIR` | `builds` | Local directory used to collect packages before installation. |
| `REMOTES_PUSH` | `lab gitea` | Git remotes used by `push:<branch>`. |

Examples:

```sh
make clone full BASE_URL=git@github.com:argvus
make clone de argvus-hyprland argvus-appearance
make clone web site-src packages
make build full
make build argvus-hyprland argvus-appearance
make install full
make install argvus-hyprland argvus-appearance
make collect BUILD_DIR=/tmp/argvus-builds
make install full BUILD_DIR=/tmp/argvus-builds
```

## Package handling

For each available installable project, `collect` copies files matching:

```text
*.pkg.tar.zst
```

An adjacent `.sig` file is copied when present. Previously collected package and signature files are removed before collection, avoiding stale packages from older builds. `install` builds and collects the requested scope before passing only its package archives to `pacman`; signature files are not included in the installation argument list.

## Git behavior

Clone targets skip any project directory that already exists. They do not fetch, reset, or modify an existing checkout. The push helper operates only on desktop projects, skips repositories without the requested local branch or configured remote, and stops if an actual push fails.

## Scope and ownership

This repository owns the cross-project workflow and directory layout. The Makefile is a thin command entry point; the implementation lives in `.tools/main.sh`. Individual ARGVUS repositories own their source code, package versions, dependencies, and project-specific build and clean implementations. When those contracts change, update the workflow script or project Makefiles together.
