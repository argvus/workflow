#!/bin/sh

set -eu

BASE_URL=${BASE_URL:-git@gitlab:argvus}
REMOTES_PUSH=${REMOTES_PUSH:-lab gitea}
PROJECTS_DE_DIST=${PROJECTS_DE_DIST:-build/dist}
BUILD_DIR=${BUILD_DIR:-builds}
ZIP_DIR=${ZIP_DIR:-zips}
ZIP_EXCLUDES=${ZIP_EXCLUDES:-'.git/* target/* tmp/* build/*'}

ROOT_DE=${ROOT_DE:-de}
ROOT_WEB=${ROOT_WEB:-web}
ROOT_MISC=${ROOT_MISC:-misc}

# argvus is the master package: every component depends on it, so no install
# order is required. argvus-greeter is not listed; its source is argvus/greeter
# and it is the third split package of the argvus PKGBUILD. Retired repositories
# live in de/retiree and are not listed. argvus-game-snake is optional.
PROJECTS_DE=${PROJECTS_DE:-'argvus argvus-accounts argvus-app-profiles
argvus-appearance argvus-boot-splash argvus-branding argvus-control-panel
argvus-display argvus-firewall argvus-fonts argvus-game-snake argvus-games
argvus-hyprland argvus-icons argvus-launcher argvus-lock argvus-notifications
argvus-portal argvus-power argvus-session argvus-taskbar argvus-wallpapers
argvus-waybar argvus-theme-catppuccin-latte argvus-theme-dracula
argvus-theme-everforest-light argvus-theme-github-light argvus-theme-gruvbox-dark
argvus-theme-gruvbox-high-dark argvus-theme-gruvbox-light argvus-theme-matrix
argvus-theme-monokai-dark argvus-theme-nord-light argvus-theme-one-dark
argvus-theme-one-light argvus-theme-rose-pine argvus-theme-silver-dark
argvus-theme-slate-dark argvus-theme-solarized-light argvus-theme-solitude
argvus-theme-sunset argvus-theme-tokyo-night argvus-theme-universe'}
PROJECTS_WEB=${PROJECTS_WEB:-'argvus-logo argvus-extras argvus-website packages'}
PROJECTS_MISC=${PROJECTS_MISC:-'TODO feedback pubkey'}

REQUIREMENTS=${REQUIREMENTS:-'rust wayland hyprland hypridle vala waybar quickshell rofi'}
SKILLS_DIR=${SKILLS_DIR:-.ai/skills}

MAKE_COMMAND=${MAKE:-make}

die() {
	echo "Error: $*" >&2
	exit 1
}

# Create one symlink, or confirm it already points to the expected target.
# Each link is checked on its own, so a partially configured checkout is completed.
ensure_link() {
	link=$1
	target=$2

	if [ -L "$link" ]; then
		current=$(readlink "$link")
		if [ "$current" = "$target" ]; then
			echo "==> $link already configured"
		else
			die "$link points to $current, expected $target"
		fi
	elif [ -e "$link" ]; then
		die "$link already exists and is not a symlink"
	else
		ln -s "$target" "$link"
		echo "==> Created $link -> $target"
	fi
}

use_claude() {
	ensure_link CLAUDE.md AGENTS.md

	mkdir -p .claude

# Create settings.json for Claude Code.
cat <<EOF > .claude/settings.json
  {
  "permissions": {
    "allow": [
      "Bash(rm -f de/*)",
      "Bash(rm -f ./de/*)"
    ],
    "deny": [
      "Bash(rm *.git*)",
      "Bash(rm *..*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\$CLAUDE_PROJECT_DIR/.claude/hooks/require-feature-branch.sh"
          }
        ]
      }
    ]
  }
}
EOF

	ensure_link .claude/skills ../.ai/skills
	ensure_link .claude/commands ../.ai/commands
}

use_opencode() {
	mkdir -p .opencode .agents
	ensure_link .agents/skills ../.ai/skills
	ensure_link .opencode/commands ../.ai/commands
}

use_codex() {
	mkdir -p .codex .agents
	ensure_link .agents/skills ../.ai/skills
	ensure_link .codex/prompts ../.ai/commands
}

clone_projects() {
	root=$1
	projects=$2

	mkdir -p "$root" || exit 1
	for project in $projects; do
		if [ -d "$root/$project" ]; then
			echo "==> Skipping $root/$project; directory already exists"
		else
			echo "==> Cloning $project..."
			git clone "$BASE_URL/$project.git" "$root/$project" || exit 1
		fi
	done
}

clone_de() {
	clone_projects "$ROOT_DE" "$PROJECTS_DE"
}

clone_web() {
	clone_projects "$ROOT_WEB" "$PROJECTS_WEB"
}

clone_misc() {
	clone_projects "$ROOT_MISC" "$PROJECTS_MISC"
}

is_project_in_list() {
	requested=$1
	projects=$2
	for candidate in $projects; do
		if [ "$candidate" = "$requested" ]; then
			return 0
		fi
	done
	return 1
}

clone_selected() {
	root=$1
	projects=$2
	scope=$3
	shift 3
	[ "$#" -gt 0 ] || die "at least one $scope project is required"

	for project do
		is_project_in_list "$project" "$projects" || \
			die "unknown $scope project '$project'"
	done
	clone_projects "$root" "$*"
}

clone() {
	[ "$#" -gt 0 ] || die "usage: make clone full|de|web|misc [PROJECT...]"

	scope=$1
	shift
	case "$scope" in
	full)
		[ "$#" -eq 0 ] || die "clone full does not accept project names"
		clone_de
		clone_web
		clone_misc
		;;
	de)
		clone_selected "$ROOT_DE" "$PROJECTS_DE" DE "$@"
		;;
	web)
		clone_selected "$ROOT_WEB" "$PROJECTS_WEB" web "$@"
		;;
	misc)
		clone_selected "$ROOT_MISC" "$PROJECTS_MISC" misc "$@"
		;;
	*)
		die "unknown clone scope '$scope'; use full, de, web or misc"
		;;
	esac
}

is_de_project() {
	is_project_in_list "$1" "$PROJECTS_DE"
}

build_projects() {
	if [ "$#" -eq 0 ]; then
		die "no projects were selected"
	fi

	for project do
		is_de_project "$project" || die "unknown DE project '$project'"

		project_dir="$ROOT_DE/$project"
		dist_dir="$project_dir/$PROJECTS_DE_DIST"

		if [ -f "$project_dir/Makefile" ] && \
			grep -Eq '^[[:space:]]*build[[:space:]]*:' "$project_dir/Makefile"; then
			# Remove stale packages only for projects that are rebuilt, so a
			# project without a build target keeps its existing artifacts.
			if [ -d "$dist_dir" ]; then
				echo "==> Removing existing packages from $dist_dir..."
				find "$dist_dir" -maxdepth 1 -type f \( \
					-name '*.pkg.tar.zst' -o -name '*.pkg.tar.zst.sig' \
				\) -delete
			fi

			echo "==> Building $project..."
			"$MAKE_COMMAND" -C "$project_dir" build || exit 1
		else
			echo "==> Skipping $project; no build target"
		fi
	done
}

build() {
	[ "$#" -gt 0 ] || die "usage: make build full|PROJECT [PROJECT...]"
	if [ "$1" = full ]; then
		[ "$#" -eq 1 ] || die "build full does not accept project names"
		for project in $PROJECTS_DE; do
			build_projects "$project"
		done
	else
		build_projects "$@"
	fi
}

collect() {
	if [ "$#" -eq 0 ]; then
		# shellcheck disable=SC2086
		set -- $PROJECTS_DE
	fi

	mkdir -p "$BUILD_DIR" || exit 1
	find "$BUILD_DIR" -maxdepth 1 -type f \( \
		-name '*.pkg.tar.zst' -o -name '*.pkg.tar.zst.sig' \
	\) -delete

	for project do
		is_de_project "$project" || die "unknown DE project '$project'"

		dist_dir="$ROOT_DE/$project/$PROJECTS_DE_DIST"
		if [ -d "$dist_dir" ]; then
			packages=$(find "$dist_dir" -maxdepth 1 -type f -name '*.pkg.tar.zst' | sort -V)
			if [ -z "$packages" ]; then
				echo "==> No package found for $project" >&2
				continue
			fi
			for package in $packages; do
				echo "==> Collecting $(basename "$package")"
				cp -f "$package" "$BUILD_DIR/" || exit 1
				if [ -f "$package.sig" ]; then
					cp -f "$package.sig" "$BUILD_DIR/" || exit 1
				fi
			done
		else
			echo "==> No $PROJECTS_DE_DIST directory for $ROOT_DE/$project" >&2
		fi
	done

	echo
	echo "==> Packages available in $BUILD_DIR/:"
	find "$BUILD_DIR" -maxdepth 1 -type f -name '*.pkg.tar.zst' -printf '  %f\n' | sort || true
	echo
}

zip_archive() {
	project_dir=$1
	zip_path=$2

	(
		cd "$project_dir" || exit 1
		set -- -rq "$zip_path" .
		set -f
		for exclude in $ZIP_EXCLUDES; do
			set -- "$@" -x "$exclude"
		done
		set +f
		zip "$@"
	)
}

zip_projects() {
	[ "$#" -gt 0 ] || die "no projects were selected"

	command -v zip >/dev/null 2>&1 || die "zip is required; install it first"

	mkdir -p "$ZIP_DIR" || exit 1
	out_dir=$(cd "$ZIP_DIR" && pwd) || exit 1

	for project do
		is_de_project "$project" || die "unknown DE project '$project'"

		project_dir="$ROOT_DE/$project"
		if [ ! -d "$project_dir" ]; then
			echo "==> Skipping $project_dir; directory does not exist" >&2
			continue
		fi

		echo "==> Compressing $project..."
		rm -f "$ZIP_DIR/$project.zip"
		zip_archive "$project_dir" "$out_dir/$project.zip" || {
			echo "==> Failed to compress $project" >&2
			continue
		}
	done

	echo
	echo "==> Zips available in $ZIP_DIR/:"
	find "$ZIP_DIR" -maxdepth 1 -type f -name '*.zip' -printf '  %f\n' | sort || true
	echo
}

zip_selected() {
	[ "$#" -gt 0 ] || die "usage: make zip full|PROJECT [PROJECT...]"
	if [ "$1" = full ]; then
		[ "$#" -eq 1 ] || die "zip full does not accept project names"
		zip_all
	else
		zip_projects "$@"
	fi
}

zip_all() {
	# shellcheck disable=SC2086
	set -- $PROJECTS_DE
	zip_projects "$@"
}

install_packages() {
	[ "$#" -gt 0 ] || die "usage: make install full|PROJECT [PROJECT...]"
	if [ "$1" = full ]; then
		[ "$#" -eq 1 ] || die "install full does not accept project names"
		build full
		collect
	else
		build "$@"
		collect "$@"
	fi

	set -- "$BUILD_DIR"/argvus-*.pkg.tar.zst
	if [ ! -e "$1" ]; then
		echo "==> No argvus packages found in $BUILD_DIR/"
		exit 1
	fi

	echo "==> Installing packages from $BUILD_DIR/..."
	sudo pacman -U --noconfirm "$@"
}

push_branch() {
	branch=$1
	branch=${branch#:}
	[ -n "$branch" ] || die "branch name is required; usage: make push:<BRANCH>"

	echo "==> Pushing branch '$branch'..."
	for project in $PROJECTS_DE; do
		project_dir="$ROOT_DE/$project"
		if [ -d "$project_dir/.git" ]; then
			if ! git -C "$project_dir" show-ref --verify --quiet "refs/heads/$branch"; then
				echo "==> Skipping $project_dir; branch '$branch' does not exist"
				continue
			fi
			for remote in $REMOTES_PUSH; do
				if git -C "$project_dir" remote get-url "$remote" >/dev/null 2>&1; then
					echo "==> Pushing $project_dir -> $remote/$branch..."
					git -C "$project_dir" push "--force-with-lease" "$remote" "$branch" || exit 1
				else
					echo "==> Skipping $project_dir; remote $remote not configured"
				fi
			done
		else
			echo "==> Skipping $project_dir; not a git repository"
		fi
	done
}

# Runs a git branch command in every DE project checkout.
# Usage: git_branch_op <label> <branch> <git-subcommand> [git args...]
git_branch_op() {
	label=$1
	branch=$2
	shift 2

	status=0
	for project in $PROJECTS_DE; do
		project_dir="$ROOT_DE/$project"
		if [ ! -d "$project_dir/.git" ]; then
			echo "==> Skipping $project_dir; not a git repository" >&2
			continue
		fi
		echo "==> $label '$branch' in $project_dir..."
		git -C "$project_dir" "$@" "$branch" || {
			echo "==> Failed to $label '$branch' in $project_dir" >&2
			status=1
		}
	done
	return "$status"
}

checkout_branch() {
	branch=$1
	branch=${branch#:}
	[ -n "$branch" ] || die "branch name is required; usage: make checkout:<BRANCH>"

	git_branch_op "check out" "$branch" checkout || exit 1
}

switch_branch() {
	branch=$1
	branch=${branch#:}
	[ -n "$branch" ] || die "branch name is required; usage: make switch:<BRANCH>"

	git_branch_op "switch to new branch" "$branch" switch -c || exit 1
}

status_projects() {
	for project in $PROJECTS_DE; do
		project_dir="$ROOT_DE/$project"
		if [ -d "$project_dir" ]; then
			echo "==> Status $project_dir..."
			git -C "$project_dir" status
		fi
	done
}

clean_dist() {
	for project in $PROJECTS_DE; do
		project_dir="$ROOT_DE/$project"
		if [ -d "$project_dir" ]; then
			echo "==> Removing $project_dir/$PROJECTS_DE_DIST..."
			rm -rf "${project_dir:?}/${PROJECTS_DE_DIST:?}"
		fi
	done
	echo "==> Removing $ROOT_DE/$PROJECTS_DE_DIST..."
	rm -rf "${ROOT_DE:?}/${PROJECTS_DE_DIST:?}"
}

clean_project() {
	project_dir=$1
	if [ -f "$project_dir/Makefile" ] && \
		grep -Eq '^[[:space:]]*clean[[:space:]]*:' "$project_dir/Makefile"; then
		echo "==> Cleaning $project_dir..."
		"$MAKE_COMMAND" -C "$project_dir" clean || exit 1
	fi
	if [ -d "$project_dir/$PROJECTS_DE_DIST" ]; then
		echo "==> Removing $project_dir/$PROJECTS_DE_DIST..."
		rm -rf "${project_dir:?}/${PROJECTS_DE_DIST:?}"
	fi
	if [ -d "$project_dir/node_modules" ]; then
		echo "==> Removing $project_dir/node_modules..."
		rm -rf "$project_dir/node_modules"
	fi
}

clean_all() {
	for project in $PROJECTS_DE; do
		clean_project "$ROOT_DE/$project"
	done
	for project in $PROJECTS_WEB; do
		clean_project "$ROOT_WEB/$project"
	done
	for project in $PROJECTS_MISC; do
		clean_project "$ROOT_MISC/$project"
	done

	echo "==> Removing $BUILD_DIR..."
	rm -rf "${BUILD_DIR:?}"
	if [ -d node_modules ]; then
		echo "==> Removing node_modules..."
		rm -rf node_modules
	fi
}

# Prints the raw --version output of one requirement. A timeout and a closed
# stdin keep a tool that waits for input, such as rofi, from hanging the run.
requirement_raw_version() {
	case "$1" in
	rust) timeout 5 rustc --version </dev/null 2>&1 ;;
	vala) timeout 5 valac --version </dev/null 2>&1 ;;
	rofi) timeout 5 rofi -version </dev/null 2>&1 ;;
	*) timeout 5 "$1" --version </dev/null 2>&1 ;;
	esac
}

# Resolves the version of one requirement. The installed binary is preferred;
# pacman is the fallback for libraries and tools with no usable --version.
# Only the line that names the tool is read, which skips log noise such as the
# first line of waybar, and only the first version-like number on it is kept.
requirement_version() {
	name=$1
	version=
	if [ "$name" != wayland ]; then
		version=$(requirement_raw_version "$name" \
			| grep -i -F -e "$name" -e version \
			| sed -n 's/[^0-9]*\([0-9][0-9]*\(\.[0-9][0-9]*\)\{1,\}\).*/\1/p' \
			| head -n 1)
	fi
	if [ -z "$version" ]; then
		# pacman reports pkgver-pkgrel; the skill lists only the pkgver.
		version=$(pacman -Q "$name" 2>/dev/null | cut -d ' ' -f 2 | sed 's/-[^-]*$//')
	fi
	printf '%s\n' "${version:-not installed}"
}

# Creates or recreates the argvus-requirements skill from REQUIREMENTS.
requirements() {
	[ -n "$REQUIREMENTS" ] || die "REQUIREMENTS is empty"

	skill_dir="$SKILLS_DIR/argvus-requirements"
	skill_file="$skill_dir/SKILL.md"
	tmp_file="$skill_file.tmp"
	generated_at=$(date '+%Y-%m-%d %H:%M')
	kernel=$(uname -r)

	mkdir -p "$skill_dir" || exit 1

	# Written to a temporary file first, so a failed run never leaves a
	# half-written skill behind.
	{
		cat <<EOF
---
name: argvus-requirements
description: Tools and versions used in ARGVUS development. Load at the start of any task to know the reference environment.
---

# ARGVUS Requirements

Generated by \`make requirements\`. Do not edit by hand: run the command again to update.

Generated at: $generated_at
Kernel: $kernel

## Tools

EOF
		# shellcheck disable=SC2086
		for name in $REQUIREMENTS; do
			echo "- $name $(requirement_version "$name")"
		done
		cat <<'EOF'

## How to use

- This list is the reference environment for ARGVUS development.
- The reference Hyprland version is 0.56.2 (see `argvus-hyprland`).
- If an installed version differs from the reference, or shows `not installed`, tell the user instead of assuming the behavior.
EOF
	} > "$tmp_file" || { rm -f "$tmp_file"; die "could not write $tmp_file"; }

	mv -f "$tmp_file" "$skill_file" || exit 1
	echo "==> Wrote $skill_file"
}

help() {
	echo
	echo "Argvus Build System"
	echo
	echo "Usage:"
	echo "  make <command>"
	echo
	echo "Commands:"
	echo
	echo "  clone full"
	echo "      Clone all Argvus projects from de/, web/ and misc/."
	echo
	echo "  clone de <PROJECT> [PROJECT...]"
	echo "      Clone selected projects into de/."
	echo
	echo "  clone web <PROJECT> [PROJECT...]"
	echo "      Clone selected projects into web/."
	echo
	echo "  clone misc <PROJECT> [PROJECT...]"
	echo "      Clone selected projects into misc/."
	echo
	echo "  build full"
	echo "      Remove existing packages and build all projects from de/."
	echo
	echo "  build <PROJECT> [PROJECT...]"
	echo "      Build only the selected projects from de/."
	echo
	echo "  collect"
	echo "      Collect all packages (*.pkg.tar.zst) from each project's"
	echo "      $PROJECTS_DE_DIST/ directory into $BUILD_DIR/."
	echo "      Stale collected packages are removed first."
	echo
	echo "  install full"
	echo "      Build and install all projects from de/."
	echo
	echo "  install <PROJECT> [PROJECT...]"
	echo "      Build and install only the selected projects from de/."
	echo
	echo "  zip-all"
	echo "      Compress every project from de/ into $ZIP_DIR/<PROJECT>.zip."
	echo "      Excluded by default: $ZIP_EXCLUDES"
	echo
	echo "  zip full"
	echo "      Same as zip-all."
	echo
	echo "  zip <PROJECT> [PROJECT...]"
	echo "      Compress only the selected projects from de/."
	echo
	echo "  codex"
	echo "      Create ->"
	echo "      ../.agents/skills links so Codex uses the workflow skills."
	echo "      ../.codex/prompts links so Codex uses the workflow prompts."
	echo
	echo "  claude"
	echo "      Create ->"
	echo "      CLAUDE.md -> AGENTS.md"
	echo "      ../.claude/skills links so Claude uses the workflow skills."
	echo "      ../.claude/commands links so Claude uses the workflow commands."
	echo
	echo "  opencode"
	echo "      Create ->"
	echo "      ../.agents/commands links so OpenCode uses the workflow commands."
	echo
	echo "  requirements"
	echo "      Create or recreate .ai/skills/argvus-requirements/SKILL.md with"
	echo "      the tools in REQUIREMENTS and their installed versions."
	echo
	echo "  clean:dist"
	echo "      Remove $PROJECTS_DE_DIST/ from all subprojects and the root $PROJECTS_DE_DIST/."
	echo
	echo "  clean:all"
	echo "      Remove build artifacts, node_modules and other generated files."
	echo
	echo "  status"
	echo "      Show Git status for all cloned DE projects."
	echo
	echo "  push:<BRANCH>"
	echo "      Push the specified branch to all configured remotes."
	echo
	echo "  checkout:<BRANCH>"
	echo "      Run 'git checkout <BRANCH>' in every DE project checkout."
	echo "      The branch must already exist locally."
	echo
	echo "  switch:<BRANCH>"
	echo "      Run 'git switch -c <BRANCH>' in every DE project checkout."
	echo "      Fails where <BRANCH> already exists."
	echo
	echo "Variables:"
	echo
	echo "  BASE_URL"
	echo "      Base Git URL used by clone targets (default: $BASE_URL)."
	echo
	echo "  PROJECTS_DE_DIST"
	echo "      Per-project package directory (default: $PROJECTS_DE_DIST)."
	echo
	echo "  BUILD_DIR"
	echo "      Package collection directory (default: $BUILD_DIR)."
	echo
	echo "  ZIP_DIR"
	echo "      Zip output directory (default: $ZIP_DIR)."
	echo
	echo "  ZIP_EXCLUDES"
	echo "      Space-separated zip exclude patterns (default: $ZIP_EXCLUDES)."
	echo
	echo "  REQUIREMENTS"
	echo "      Space-separated tools listed by 'make requirements'"
	echo "      (default: $REQUIREMENTS)."
	echo
	echo "  SKILLS_DIR"
	echo "      Skills directory that 'make requirements' writes into"
	echo "      (default: $SKILLS_DIR)."
	echo
	echo "Examples:"
	echo
	echo "  make clone full"
	echo "  make clone de argvus-hyprland argvus-appearance"
	echo "  make clone web argvus-website packages"
	echo "  make build full"
	echo "  make build argvus-hyprland argvus-appearance"
	echo "  make collect"
	echo "  make install full"
	echo "  make install argvus-hyprland argvus-appearance"
	echo "  make zip-all"
	echo "  make zip argvus-hyprland argvus-appearance"
	echo "  make claude"
	echo "  make requirements"
	echo "  make requirements REQUIREMENTS='rust hyprland'"
	echo "  make clean:dist"
	echo "  make clean:all"
	echo "  make push:main"
	echo "  make checkout:main"
	echo "  make switch:feature/my-change"
	echo
	echo "Change Git provider:"
	echo
	echo "  make clone full BASE_URL=git@github.com:argvus"
}

command=${1:-help}
# A bare `shift` aborts POSIX shells such as dash when there are no arguments,
# even with `|| true`, so only shift when there is something to remove.
if [ "$#" -gt 0 ]; then
	shift
fi

case "$command" in
	help)
		help
		;;
	clone)
		clone "$@"
		;;
	build)
		build "$@"
		;;
	collect)
		collect
		;;
	zip)
		zip_selected "$@"
		;;
	zip-all)
		zip_all
		;;
	install)
		install_packages "$@"
		;;
	push)
		[ "$#" -eq 1 ] || die "branch name is required; usage: make push:<BRANCH>"
		push_branch "$1"
		;;
	checkout)
		[ "$#" -eq 1 ] || die "branch name is required; usage: make checkout:<BRANCH>"
		checkout_branch "$1"
		;;
	switch)
		[ "$#" -eq 1 ] || die "branch name is required; usage: make switch:<BRANCH>"
		switch_branch "$1"
		;;
	status)
		status_projects
		;;
	clean:dist)
		clean_dist
		;;
	clean:all)
		clean_all
		;;
	codex)
		use_codex
		;;
	claude)
		use_claude
		;;
	opencode)
		use_opencode
		;;
	requirements)
		requirements
		;;
	*)
		die "unknown command '$command'"
		;;
esac
