#!/bin/bash
# block-interactive-commands.sh
# PreToolUse hook: blocks commands that require stdin input
# Exit 2 = block the action, stderr = feedback to Claude

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Commands that require interactive input
INTERACTIVE_PATTERNS=(
  "git add -i"
  "git add --interactive"
  "git rebase -i"
  "git rebase --interactive"
  "^read "
  "^select "
  "npm init$"
  "ssh-keygen"
  "passwd"
  "sudo -S"
  "vim "
  "nano "
  "vi "
  "emacs "
  "less "
  "more "
  "top$"
  "htop$"
  "mysql$"
  "psql$"
  "mongo$"
  "python$"
  "node$"
  "irb$"
)

for pattern in "${INTERACTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "BLOCKED: Command '$COMMAND' requires interactive input. Use non-interactive flags (e.g., npm init -y, git add .) or find an alternative." >&2
    exit 2
  fi
done

exit 0
