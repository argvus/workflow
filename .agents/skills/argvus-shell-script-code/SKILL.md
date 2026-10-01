---
name: argvus-shell-script-code
description: Shell script best practices for ARGVUS workflow and desktop environment projects
---

# Shell Script Best Practices for ARGVUS

## Overview

This skill guides shell script development for ARGVUS projects, emphasizing POSIX compatibility (especially dash), reliability in production workflows, and integration with the Arch Linux/Hyprland ecosystem. Shell scripts in ARGVUS orchestrate builds, deployments, and system configuration, so correctness and maintainability are critical.

## Core Principles

1. **POSIX Shell First** - Write scripts that run on dash (POSIX reference implementation). Bash-isms fragment the codebase across systems where /bin/sh varies.
2. **Explicit Error Handling** - Every command that can fail must be checked or deliberately ignored with comment justification.
3. **Clear Ownership** - Script entry points, helper functions, and error responsibilities must be obvious to readers.
4. **Minimal External Dependencies** - Prefer shell builtins and POSIX tools (grep, sed, awk) over specialized binaries not guaranteed on Arch.
5. **Test-Driven Validation** - Complex logic deserves unit testing or integration tests before deployment in the workflow.

## 1. POSIX Shell Compatibility

### Use Only POSIX Features

**Good:**
```bash
#!/bin/sh
# POSIX shell - runs on dash, bash, zsh, ksh

if [ -f "$file" ]; then
    echo "File exists"
fi

# Arithmetic with POSIX $((…))
count=$((count + 1))

# Parameter expansion
name="${var:-default}"
```

**Avoid:**
```bash
#!/bin/bash
# Non-portable bash extensions

if [[ -f $file ]]; then  # [[ ]] is bash-only
    echo "File exists"
fi

# Bash arrays (use functions with stdout instead)
arr=(a b c)
```

### Common Bash-isms to Avoid

| Bash Feature | POSIX Alternative | Notes |
|---|---|---|
| `[[ ]]` conditionals | `[ ]` or `test` | `[[ ]]` does regex matching only in bash |
| `=~` regex operator | `grep` or `expr` | Use grep for pattern matching |
| `${var[@]}` arrays | Functions returning values | Pass arguments via stdout |
| `local` in functions | No declaration; prefix with function name | POSIX functions are global scope |
| `<(…)` process substitution | Pipes or temp files | Not POSIX; use `|` or `mktemp` |
| `${var:offset:length}` substring | `cut` or `expr` | POSIX parameter expansion is simpler |
| `declare -x` | `export VAR=value` | Simpler, more portable |

### Shebang Line

**Always use:**
```bash
#!/bin/sh
```

Not `#!/bin/bash` unless you have documented bash-only requirements (rare in ARGVUS). On Arch, `/bin/sh` is dash by default; on other systems it varies.

## 2. Error Handling and Exit Codes

### Set -e Pitfalls

**Avoid bare `set -e`:**
```bash
#!/bin/sh
set -e  # Exits on first error, but behavior is unpredictable

command1  # If this fails, script exits
command2
```

**Problems:**
- `set -e` doesn't trigger in command substitutions or pipes (unless `set -o pipefail`, which is bash-only).
- Makes debugging harder because exit happens silently.

**Better: explicit error checks**
```bash
#!/bin/sh
set -e

if ! command1; then
    echo "command1 failed with exit code $?" >&2
    exit 1
fi

command2 || {
    echo "command2 failed" >&2
    exit 1
}
```

### Check Exit Codes Explicitly

**Pattern for critical operations:**
```bash
run_command() {
    if ! "$@"; then
        local exit_code=$?
        echo "ERROR: Command failed with exit code $exit_code" >&2
        echo "Command: $*" >&2
        return "$exit_code"
    fi
}

# Use it
run_command make build || exit 1
```

### Trap Cleanup

Always clean up temporary resources:

```bash
#!/bin/sh

cleanup() {
    local exit_code=$?
    rm -f "$temp_file"
    exit "$exit_code"
}

trap cleanup EXIT

temp_file=$(mktemp)
echo "data" > "$temp_file"
# Script can exit or fail; cleanup always runs
```

## 3. Argument Parsing and Validation

### Manual Parsing (No getopt for Portability)

**Good for simple scripts:**
```bash
#!/bin/sh

usage() {
    cat <<EOF
Usage: $0 [-v] [-o OUTPUT] INPUT
    -v          Verbose mode
    -o OUTPUT   Output file (default: stdout)
    -h          Show this help

Arguments:
    INPUT       Input file to process
EOF
    exit "${1:-0}"
}

verbose=0
output=""

while [ $# -gt 0 ]; do
    case "$1" in
        -v)
            verbose=1
            shift
            ;;
        -o)
            output="$2"
            [ -n "$output" ] || { echo "ERROR: -o requires argument" >&2; exit 1; }
            shift 2
            ;;
        -h)
            usage 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "ERROR: Unknown option: $1" >&2
            usage 1
            ;;
        *)
            break
            ;;
    esac
done

# Validate required arguments
if [ $# -lt 1 ]; then
    echo "ERROR: INPUT required" >&2
    usage 1
fi

input="$1"

if [ ! -f "$input" ]; then
    echo "ERROR: Input file not found: $input" >&2
    exit 1
fi

echo "Processing: $input"
[ "$verbose" -eq 1 ] && echo "Verbose mode enabled"
[ -n "$output" ] && echo "Output to: $output"
```

### Guard Against Missing Arguments

**Critical pattern from ARGVUS `.tools/main.sh` fix:**

```bash
#!/bin/sh

# WRONG - crashes in dash with no arguments
if true; then
    shift  # ERROR if $# is 0
fi

# RIGHT - explicit guard
if [ "$#" -gt 0 ]; then
    shift
fi

# Or use loop with break
while [ $# -gt 0 ]; do
    arg="$1"
    shift
    # process $arg
done
```

## 4. Variable and Quoting Best Practices

### Always Quote Variables

**Good:**
```bash
#!/bin/sh

file="path with spaces.txt"

# Quoted - prevents word splitting
cat "$file"
rm "$file"

# Function arguments
run_cmd "$1" "$2"
```

**Bad:**
```bash
# Unquoted - splits on spaces/tabs/newlines
cat $file           # Breaks if $file has spaces
mkdir $dirname      # Creates multiple directories if spaces exist
```

### Parameter Expansion Defaults

```bash
#!/bin/sh

# Use default if unset
value="${VAR:-default_value}"

# Use default if unset or empty
value="${VAR:=default_value}"

# Error if unset
value="${VAR:?ERROR: VAR must be set}"

# Substring expansion (limited POSIX support)
# Better: use expr or cut
first_char=$(echo "$string" | cut -c1)
```

### Avoid Eval

**Never:**
```bash
#!/bin/sh
eval "$user_input"  # Arbitrary code execution vulnerability
```

**Safe alternatives:**
```bash
#!/bin/sh
# Pass as arguments
run_command "$@"

# Use case statement for safe dispatch
case "$action" in
    build)  make build ;;
    test)   make test ;;
    *)      echo "Unknown action: $action" >&2; exit 1 ;;
esac
```

## 5. Function Organization

### Clear Naming and Documentation

```bash
#!/bin/sh

# Public functions: no prefix
build_project() {
    # Brief description of what this does
    # Arguments: none
    # Returns: 0 on success, 1 on failure
    # Modifies: global $BUILD_OUTPUT

    echo "Building..."
    if make build > "$BUILD_OUTPUT" 2>&1; then
        return 0
    else
        echo "Build failed. See $BUILD_OUTPUT" >&2
        return 1
    fi
}

# Private functions: _prefix
_validate_environment() {
    # Only called internally
    [ -n "$BUILD_DIR" ] || { echo "ERROR: BUILD_DIR not set" >&2; return 1; }
}

main() {
    # Entry point
    _validate_environment || exit 1
    build_project || exit 1
    echo "Success"
}

main "$@"
```

### Return Values vs. Stdout

**Pattern 1: Return code for status**
```bash
is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
    return $?
}

if is_package_installed "hyprland"; then
    echo "Hyprland is installed"
fi
```

**Pattern 2: Stdout for data**
```bash
get_package_version() {
    pacman -Q "$1" | awk '{print $2}'
}

version=$(get_package_version "hyprland")
echo "Version: $version"
```

## 6. Testing and Validation

### Unit Testing Pattern

```bash
#!/bin/sh

# Source the script under test
. ./build.sh

test_extract_version() {
    result=$(extract_version "hyprland 0.42.0")
    expected="0.42.0"

    if [ "$result" = "$expected" ]; then
        echo "PASS: extract_version"
        return 0
    else
        echo "FAIL: extract_version"
        echo "  Expected: $expected"
        echo "  Got: $result"
        return 1
    fi
}

test_is_valid_package_name() {
    for name in "hyprland" "xorg-server" "systemd-libs"; do
        if ! is_valid_package_name "$name"; then
            echo "FAIL: is_valid_package_name should accept '$name'"
            return 1
        fi
    done
    echo "PASS: is_valid_package_name"
    return 0
}

# Run tests
test_count=0
pass_count=0

for test in test_extract_version test_is_valid_package_name; do
    test_count=$((test_count + 1))
    if $test; then
        pass_count=$((pass_count + 1))
    fi
done

echo "$pass_count/$test_count tests passed"
[ "$pass_count" -eq "$test_count" ] || exit 1
```

### Integration Testing

```bash
#!/bin/sh

# Test the full build workflow
test_build_workflow() {
    local temp_dir
    temp_dir=$(mktemp -d) || { echo "mktemp failed" >&2; return 1; }

    trap "rm -rf '$temp_dir'" RETURN

    cd "$temp_dir"
    git clone "$TEST_REPO" . || return 1
    make build || return 1

    [ -f "build/output.bin" ] || { echo "Build artifact missing" >&2; return 1; }
    echo "Integration test PASS"
    return 0
}

test_build_workflow || exit 1
```

## 7. Comments and Documentation

### Comment Structure

```bash
#!/bin/sh

###############################################################################
# Script: build-argvus.sh
# Purpose: Build ARGVUS components for Arch Linux
# Usage: ./build-argvus.sh [-j4] [component]
# Author: ARGVUS Team
# Dependencies: make, gcc, git
###############################################################################

# Public functions

# build_rust_component()
# Builds a Rust component from source
# Arguments:
#   $1 - Component name (e.g., 'hyprland-config')
# Returns:
#   0 on success, 1 if component not found
# Modifies:
#   - stdout: build messages
#   - stderr: error messages
build_rust_component() {
    local component="$1"
    # ... implementation
}

# Internal functions (prefixed with _)

# _log()
# Print timestamped log message
# Arguments:
#   $1 - Log level (INFO, WARN, ERROR)
#   $2+ - Message
_log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >&2
}

# Avoid inline comments that clutter logic
# Good: explain WHY, not WHAT
_log INFO "Checking for stale build artifacts (prevents cache conflicts)"

# Bad: over-commenting
# i=$((i + 1))  # Increment i by 1
```

### TODO Convention

```bash
#!/bin/sh

# TODO: Implement parallel build support (issue #42)
# FIXME: This breaks on macOS due to sed differences
# HACK: Temporary workaround until upstream PR is merged
# NOTE: This must run before the cache is populated
# WARN: Changes here require updates to CI/CD pipeline
```

## 8. ARGVUS-Specific Patterns

### Integration with Make

```bash
#!/bin/sh
# helpers/build.sh - Called by Makefile

# Accept MAKE variables as environment
BUILD_TYPE="${BUILD_TYPE:-debug}"
JOBS="${JOBS:-4}"

# Export for child processes
export BUILD_TYPE JOBS

# Validate make is available
if ! command -v make >/dev/null 2>&1; then
    echo "ERROR: make not found" >&2
    exit 1
fi

# Run make with consistent flags
make -j"$JOBS" BUILD_TYPE="$BUILD_TYPE" all || exit 1
```

### Symlink Management (ARGVUS Workflow)

```bash
#!/bin/sh
# Link Claude skill into .claude/skills

link_skill() {
    local skill_name="$1"
    local source="$PWD/.agents/skills/$skill_name"
    local target="$HOME/.claude/skills/current/$skill_name"

    if [ ! -d "$source" ]; then
        echo "ERROR: Skill directory not found: $source" >&2
        return 1
    fi

    # Remove old link if it exists
    rm -f "$target"

    # Create new link
    if ! ln -s "$source" "$target" 2>/dev/null; then
        # On some systems, try relative symlink
        local rel_source
        rel_source=$(realpath --relative-to="$(dirname "$target")" "$source")
        ln -s "$rel_source" "$target" || return 1
    fi

    echo "Linked: $target -> $source"
    return 0
}

link_skill "$1" || exit 1
```

### Collecting Build Artifacts

```bash
#!/bin/sh
# Correctly identify and collect .pkg.tar.zst files

collect_packages() {
    local source_dir="$1"
    local dest_dir="$2"

    if [ ! -d "$source_dir" ]; then
        echo "ERROR: Source directory not found: $source_dir" >&2
        return 1
    fi

    mkdir -p "$dest_dir" || return 1

    # Use correct pattern matching - .pkg.tar.zst not just .zst
    # This prevents matching other .zst files (e.g., caches)
    find "$source_dir" -maxdepth 1 -name '*.pkg.tar.zst' -type f | while read -r pkg; do
        cp "$pkg" "$dest_dir/" || return 1
        echo "Collected: $(basename "$pkg")"
    done

    return 0
}

collect_packages "$BUILD_DIR" "$OUTPUT_DIR" || exit 1
```

## 9. Common Pitfalls and Solutions

| Pitfall | Problem | Solution |
|---|---|---|
| Unquoted variables | Word splitting on spaces | Always quote: `"$var"` |
| Missing error checks | Silently continues after failure | Check `$?` or use `\|\|` operator |
| `shift` without guard | Crashes with "illegal number of arguments" | Guard: `if [ "$#" -gt 0 ]; then shift; fi` |
| `[ ]` vs `[[ ]]` | `[[ ]]` not available in dash | Use `[ ]` for POSIX compatibility |
| Bare `set -e` | Unpredictable exit behavior | Use explicit error checks instead |
| Subprocess failures silent | Errors in pipes/subshells ignored | Explicitly check or store result |
| No cleanup on exit | Temporary files left behind | Use `trap` with cleanup function |
| Hardcoded paths | Scripts break on different systems | Use `$HOME`, `$(pwd)`, or pass as arguments |
| Command injection | Eval of user input executes code | Never eval; use `case` statements for dispatch |
| Missing shebang | Script runs with wrong interpreter | Always: `#!/bin/sh` |

## 10. Linting and Validation

### ShellCheck Integration

Use `shellcheck` to validate scripts before committing:

```bash
# Install on Arch
sudo pacman -S shellcheck

# Validate a script
shellcheck build.sh

# Enable specific rules
shellcheck -S warning build.sh

# Common warnings to address
# SC2086: Double quote to prevent globbing
# SC2181: Check exit code directly
# SC2046: Quote this to prevent word splitting
# SC2006: Use $(...) instead of backticks
```

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

for script in $(git diff --cached --name-only | grep -E '\.sh$|^[^.]*$' | grep -v '\.' ); do
    if head -1 "$script" | grep -q '^#!/bin/sh'; then
        if ! shellcheck "$script"; then
            echo "ERROR: $script failed shellcheck" >&2
            exit 1
        fi
    fi
done
```

## 11. Debugging Techniques

### Enable Trace Mode

```bash
#!/bin/sh

# Run script with debugging
sh -x script.sh

# Enable in script
set -x  # Print each command before execution
set -v  # Print each line as read

# Disable for specific sections
set +x
make_build_silently
set -x
```

### Debug Function

```bash
#!/bin/sh

DEBUG="${DEBUG:-0}"

debug() {
    [ "$DEBUG" -eq 1 ] && echo "DEBUG: $*" >&2
    return 0
}

# Usage
debug "Variable value: $var"
DEBUG=1 ./script.sh
```

### Validate Syntax Without Running

```bash
sh -n script.sh  # Check syntax only
```

## 12. Security Considerations

### Avoid Shell Injection

**Bad:**
```bash
user_cmd="$1"
eval "$user_cmd"  # Arbitrary code execution
```

**Good:**
```bash
case "$1" in
    build)  make build ;;
    clean)  make clean ;;
    *)      echo "Unknown command" >&2; exit 1 ;;
esac
```

### Secure Temp Files

```bash
#!/bin/sh

# Create temp file securely
temp_file=$(mktemp) || { echo "mktemp failed" >&2; exit 1; }
trap "rm -f '$temp_file'" EXIT

# Use secure temp directory
temp_dir=$(mktemp -d) || { echo "mktemp -d failed" >&2; exit 1; }
trap "rm -rf '$temp_dir'" EXIT
```

### Handle Sensitive Data

```bash
#!/bin/sh

# Don't log passwords or tokens
log_command() {
    if echo "$1" | grep -q 'password\|token'; then
        echo "Running sensitive command (output redacted)" >&2
    else
        echo "Running: $1" >&2
    fi
}

# Clear sensitive variables when done
unset API_KEY
```

## Checklist for ARGVUS Shell Scripts

- [ ] Shebang is `#!/bin/sh`
- [ ] No bash-specific features (test with `shellcheck -S warning`)
- [ ] All variables are quoted: `"$var"`
- [ ] Exit codes checked explicitly or errors fatal
- [ ] Trap set for cleanup (especially `mktemp`)
- [ ] Guard conditions for `shift` and array access
- [ ] Argument validation with `usage()` function
- [ ] Help text available with `-h` or `--help`
- [ ] POSIX-only tools used (grep, sed, awk, cut)
- [ ] No hardcoded absolute paths
- [ ] Comments explain WHY, not WHAT
- [ ] Functions are documented (purpose, args, returns)
- [ ] Integration tested with `make` targets
- [ ] Passes `shellcheck` with no warnings
- [ ] No eval of user input
- [ ] Temp files cleaned up safely

## References

- POSIX Shell Specification: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html
- ShellCheck: https://www.shellcheck.net/
- Defensive BASH Programming: http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- ARGVUS Workflow: See AGENTS.md for skill integration
