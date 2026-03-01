#!/bin/bash
WORKDIR="/home/hsieh89t/.openclaw/workspace/config"
cd "$WORKDIR" || exit 1

echo "=== Agent Auto Backup ==="

git add .
STAGED_FILES=$(git diff --cached --name-only)

if [[ -z "$STAGED_FILES" ]]; then
  echo "No changes detected."
  echo "=== Done ==="
  exit 0
fi

SENSITIVE_PATTERNS=(".env" "token" "secret" "credentials" "secrets/" "id_rsa" "id_ed25519" ".ssh")
SENSITIVE_HITS=()

while IFS= read -r file; do
  for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if [[ "$file" == *"$pattern"* ]]; then
      SENSITIVE_HITS+=("$file")
      break
    fi
  done
done <<< "$STAGED_FILES"

if [[ ${#SENSITIVE_HITS[@]} -gt 0 ]]; then
  echo "[ABORT] Sensitive files detected in staging area:"
  for hit in "${SENSITIVE_HITS[@]}"; do
    echo " - $hit"
  done
  echo "Remove or unstage these files before backing up."
  echo "=== Done ==="
  exit 2
fi

COMMIT_MSG="auto backup $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG"
git push origin main
echo "Backup pushed."

echo "=== Done ==="
