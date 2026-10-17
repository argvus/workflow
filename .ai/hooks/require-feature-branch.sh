#!/usr/bin/env bash
input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name')
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
branch=$(git symbolic-ref --short -q HEAD 2>/dev/null)

# Only takes action if on main/master
case "$branch" in main|master) ;; *) exit 0 ;; esac

MSG="Blocked: you are on branch '$branch'. Ask the user for the name of the new editing branch and create it using 'git switch -c <name>' before making any changes."

# Editing tools: always lock
if [ "$tool" != "Bash" ]; then
  echo "$MSG" >&2
  exit 2
fi

# Bash: enables branch creation
if echo "$cmd" | grep -Eq '^\s*git\s+(switch\s+-c|checkout\s+-b)\b'; then
  exit 0
fi

# Bash: blocks commands that modify files or history
if echo "$cmd" | grep -Eq '(^|[;&|[:space:]])(rm|mv|cp|touch|mkdir|tee|truncate|chmod|sed\s+-i|git\s+(commit|push|merge|rebase|reset|revert|cherry-pick|apply|add|rm|mv))\b|[^>]>[^&]|>>'; then
  echo "$MSG" >&2
  exit 2
fi

exit 0
