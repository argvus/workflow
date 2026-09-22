#!/bin/sh

set -eu

BASE_URL=${BASE_URL:-git@gitlab:argvus}
REMOTES_PUSH=${REMOTES_PUSH:-lab gitea}
PROJECTS_DE_DIST=${PROJECTS_DE_DIST:-build/dist}
BUILD_DIR=${BUILD_DIR:-builds}

ROOT_DE=${ROOT_DE:-de}
ROOT_WEB=${ROOT_WEB:-web}
ROOT_MISC=${ROOT_MISC:-misc}

PROJECTS_DE=${PROJECTS_DE:-'argvus argvus-appearance argvus-app-profiles
argvus-control-panel argvus-widget-telemetry argvus-display
argvus-firewall argvus-icons argvus-lock
argvus-network argvus-notifications argvus-portal
argvus-power argvus-terminal argvus-system-monitor
argvus-session argvus-hyprland argvus-launcher
argvus-taskbar argvus-i18n argvus-splash argvus-fonts
argvus-wallpapers argvus-removable-devices argvus-greeter
argvus-accounts argvus-control-center argvus-taskbar-calendar
argvus-theme-splash argvus-tui'}
PROJECTS_WEB=${PROJECTS_WEB:-'argvus-logo argvus-extras site-src packages'}
PROJECTS_MISC=${PROJECTS_MISC:-'TODO feedback pubkey'}

MAKE_COMMAND=${MAKE:-make}

die() {
	echo "Error: $*" >&2
	exit 1
}

use_claude() {
	ln -s AGENTS.md CLAUDE.md

	mkdir -p .claude
	ln -s ../.agents/skills .claude/skills
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

		if [ -d "$dist_dir" ]; then
			echo "==> Removing existing packages from $dist_dir..."
			find "$dist_dir" -maxdepth 1 -type f \( \
				-name '*.pkg.tar.zst' -o -name '*.pkg.tar.zst.sig' \
			\) -delete
		fi

		if [ -f "$project_dir/Makefile" ] && \
			grep -Eq '^[[:space:]]*build[[:space:]]*:' "$project_dir/Makefile"; then
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
	mkdir -p "$BUILD_DIR" || exit 1
	find "$BUILD_DIR" -maxdepth 1 -type f \( \
		-name '*.pkg.tar.zst' -o -name '*.pkg.tar.zst.sig' \
	\) -delete

	for project in $PROJECTS_DE; do
		dist_dir="$ROOT_DE/$project/$PROJECTS_DE_DIST"
		if [ -d "$dist_dir" ]; then
			packages=$(find "$dist_dir" -maxdepth 1 -type f -name '*.zst' | sort -V)
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

install_packages() {
	collect || exit 1

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
					git -C "$project_dir" push "$remote" "$branch" || exit 1
				else
					echo "==> Skipping $project_dir; remote $remote not configured"
				fi
			done
		else
			echo "==> Skipping $project_dir; not a git repository"
		fi
	done
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
		grep -q '^clean:' "$project_dir/Makefile"; then
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
	echo "  install"
	echo "      Install all collected argvus-*.pkg.tar.zst packages from $BUILD_DIR/"
	echo "      using pacman."
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
	echo "Examples:"
	echo
	echo "  make clone full"
	echo "  make clone de argvus-hyprland argvus-appearance"
	echo "  make clone web site-src packages"
	echo "  make build full"
	echo "  make build argvus-hyprland argvus-appearance"
	echo "  make collect"
	echo "  make install"
	echo "  make clean:dist"
	echo "  make clean:all"
	echo "  make push:main"
	echo
	echo "Change Git provider:"
	echo
	echo "  make clone full BASE_URL=git@github.com:argvus"
}

command=${1:-help}
shift 2>/dev/null || true

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
	install)
		install_packages
		;;
	push)
		[ "$#" -eq 1 ] || die "branch name is required; usage: make push:<BRANCH>"
		push_branch "$1"
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
	claude)
		use_claude
		;;
	*)
		die "unknown command '$command'"
		;;
esac
