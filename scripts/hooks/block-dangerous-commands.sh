#!/bin/bash
# block-dangerous-commands.sh
# PreToolUse hook: blocks destructive bash commands
# Exit 2 = block the action, stderr = feedback to Claude

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Patterns to block
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \."
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate table"
  "> /dev/sda"
  "mkfs\."
  "dd if="
  ":(){:|:&};:"
  "chmod -R 777"
  "chown -R"
  "curl.*| bash"
  "curl.*| sh"
  "wget.*| bash"
  "wget.*| sh"
  "eval \""
  "npm publish"
  "git push.*main"
  "git push.*master"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "BLOCKED: Command matches dangerous pattern '$pattern'. This command is not allowed." >&2
    exit 2
  fi
done

exit 0
