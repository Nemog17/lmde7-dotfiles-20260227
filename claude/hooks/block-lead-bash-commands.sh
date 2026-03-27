#!/usr/bin/env bash
# Block the lead from running infrastructure/code-modifying bash commands.
# Allow: read-only diagnostics (git status/log/diff, gh run view, grep, ls, bun run check, etc.)
# Block: git push/commit/add, wrangler deploy/secret/pages, docker build/push, sed -i, composer/bun/npm add/remove, rm/mv/cp on code files

TMP=$(mktemp)
trap "rm -f $TMP" EXIT
cat > "$TMP"

# If running as teammate (CLAUDE_NO_HUD=1) → allow
[ "${CLAUDE_NO_HUD}" = "1" ] && exit 0

python3 << EOF
import json, re, sys

with open("$TMP") as f:
    data = json.load(f)

command = data.get('tool_input', {}).get('command', '')

BLOCKED_PATTERNS = [
    (r'\bgit\s+push\b',   'git push'),
    (r'\bgit\s+commit\b', 'git commit'),
    (r'\bgit\s+add\b',    'git add'),
    (r'\bwrangler\s+deploy\b',             'wrangler deploy'),
    (r'\bwrangler\s+secret\b',             'wrangler secret'),
    (r'\bwrangler\s+pages\b',              'wrangler pages'),
    (r'\bwrangler\s+containers\s+delete\b','wrangler containers delete'),
    (r'\bdocker\s+build\b',         'docker build'),
    (r'\bdocker\s+push\b',          'docker push'),
    (r'\bdocker[\s-]compose\s+up\b','docker compose up'),
    (r'\bsed\s+[^ ]*-[a-zA-Z]*i',  'sed -i (edicion in-place)'),
    (r'\bawk\s+[^ ]*-[a-zA-Z]*i',  'awk -i (edicion in-place)'),
    (r'\bcomposer\s+(require|remove)\b', 'composer require/remove'),
    (r'\bbun\s+(add|remove)\b',          'bun add/remove'),
    (r'\bnpm\s+(install|uninstall|ci)\b','npm install/uninstall'),
    (r'\b(rm|mv|cp)\b.*\.(vue|ts|tsx|js|jsx|php|css|scss|sql|sh|yaml|yml|toml|lock)',
     'rm/mv/cp en archivos de codigo'),
]

for pattern, label in BLOCKED_PATTERNS:
    if re.search(pattern, command):
        msg = {
            "decision": "block",
            "reason": (
                f"LEAD NO EJECUTA INFRA/CODIGO: '{label}' esta bloqueado. "
                "Delega al teammate correcto: "
                "git push/commit → devops | "
                "wrangler/docker → devops | "
                "composer/bun add → backend o frontend | "
                "sed/awk in-place → usar Edit tool via teammate. "
                "El lead solo diagnostica, delega y verifica."
            )
        }
        print(json.dumps(msg))
        sys.exit(0)

sys.exit(0)
EOF
