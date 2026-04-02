#!/bin/bash
# validate-comm-update.sh
# PostToolUse hook: validates COMM.md updates have required fields
# Runs after Edit|Write on files matching *COMM.md*

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check COMM.md files
if [[ "$FILE_PATH" != *"COMM.md"* ]]; then
  exit 0
fi

# Verify the file has a Status field
if ! grep -q "^## Status" "$FILE_PATH"; then
  echo "WARNING: COMM.md update is missing ## Status field" >&2
fi

# Verify timestamps section exists
if ! grep -q "^## Timestamps" "$FILE_PATH"; then
  echo "WARNING: COMM.md update is missing ## Timestamps section" >&2
fi

exit 0
