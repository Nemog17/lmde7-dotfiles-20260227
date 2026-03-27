#!/usr/bin/env bash
# Block the lead from directly editing code or infra files.
# Allow: .md, .json, memory files
# Block: .vue, .ts, .tsx, .js, .jsx, .css, .scss (frontend)
#        .php, .blade (backend)
#        .sql (database)
#        .sh, .bash, .yaml, .yml, .toml, .env, .lock (infra/config)

INPUT=$(cat)

# If running as teammate (CLAUDE_NO_HUD=1) → allow
[ "${CLAUDE_NO_HUD}" = "1" ] && exit 0

file_path=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))")

# If no file_path, allow
[ -z "$file_path" ] && exit 0

# Extract extension
ext="${file_path##*.}"

# Check if it's a code file
case "$ext" in
  vue|ts|tsx|js|jsx|css|scss|\
  php|blade|\
  sql|\
  sh|bash|\
  yaml|yml|toml|\
  env|lock)
    echo '{"decision":"block","reason":"LEAD NO ESCRIBE CODIGO NI CONFIG. Delega al teammate correcto: Frontend (vue/ts/css/scss) → frontend | Backend (php/blade) → backend | Database (sql) → dba | Infra/Config (sh/yaml/toml/env/lock) → devops. Flujo: Lead diagnostica → prompt-engineer crafta prompt → teammate aplica."}'
    ;;
  *)
    exit 0
    ;;
esac
