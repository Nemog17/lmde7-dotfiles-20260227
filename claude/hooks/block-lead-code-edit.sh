#!/usr/bin/env bash
# Block the lead from directly editing code files.
# Allow: .md, .json, memory files, config files
# Block: .vue, .ts, .tsx, .js, .jsx, .php, .css, .scss

file_path=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))")

# If no file_path, allow
[ -z "$file_path" ] && exit 0

# Extract extension
ext="${file_path##*.}"

# Check if it's a code file
case "$ext" in
  vue|ts|tsx|js|jsx|php|css|scss)
    echo '{"decision":"block","reason":"LEAD NO ESCRIBE CODIGO. Delega al teammate correcto: Frontend (Vue/TS/CSS) → gemini-agent | Backend (PHP/Laravel) → codex-agent | Database → dba | Infra → devops. Flujo: Lead diagnostica → prompt-engineer crafta prompt → teammate aplica."}'
    ;;
  *)
    exit 0
    ;;
esac
