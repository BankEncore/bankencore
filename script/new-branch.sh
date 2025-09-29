#!/usr/bin/env bash
set -euo pipefail

# ----- Configure your scopes here -----
SCOPES=(app models controllers views js css db auth search parties phones emails addresses ci docs misc)
TYPES=(feat fix chore refactor docs test perf ci spike release hotfix)
DEFAULT_BASE="main"
# --------------------------------------

die(){ echo "error: $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || die "missing '$1'"; }

need git
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not in a git repo"

# Ensure base exists
git fetch -q origin || true
BASE_BRANCH="${DEFAULT_BASE}"
git show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}" || {
  git show-ref --verify --quiet "refs/heads/${BASE_BRANCH}" || die "base branch '${BASE_BRANCH}' not found"
}

clean_status(){
  [[ -z "$(git status --porcelain)" ]]
}

if ! clean_status; then
  echo "Working tree not clean."
  read -rp "Continue anyway? [y/N] " ans
  [[ "${ans:-}" =~ ^[Yy]$ ]] || exit 1
fi

select_from(){
  local prompt="$1"; shift
  local -n arr=$1
  local choice
  PS3="$prompt "
  select choice in "${arr[@]}" "custom"; do
    [[ -n "${choice:-}" ]] || { echo "invalid"; continue; }
    if [[ "$REPLY" -eq $((${#arr[@]}+1)) ]]; then
      read -rp "Enter custom value (kebab-case): " custom
      echo "${custom}"
      break
    else
      echo "${choice}"
      break
    fi
  done
}

kebabize(){
  # to-lower, spaces/underscores -> '-', strip invalid chars, squeeze dashes
  tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[ _]+/-/g; s/[^a-z0-9-]+//g; s/-+/-/g; s/^-|-$//g'
}

echo "Select type:"
TYPE=$(select_from "> " TYPES)
[[ -n "$TYPE" ]] || die "type required"

echo "Select scope:"
SCOPE=$(select_from "> " SCOPES)
[[ -n "$SCOPE" ]] || die "scope required"

read -rp "Short description (3–5 words): " DESC_RAW
DESC=$(printf "%s" "${DESC_RAW}" | kebabize)
[[ -n "$DESC" ]] || die "description required"

read -rp "Ticket ID (optional, e.g., ABC-123 or #456): " TICKET_RAW
TICKET=$(printf "%s" "${TICKET_RAW}" | tr -d '[:space:]')

BRANCH="${TYPE}/${SCOPE}/${DESC}"
[[ -n "$TICKET" ]] && BRANCH="${BRANCH}-${TICKET}"

# length sanity
[[ ${#BRANCH} -le 100 ]] || die "branch name too long (${#BRANCH} > 100): ${BRANCH}"

echo
echo "Base branch: ${BASE_BRANCH}"
echo "Branch name: ${BRANCH}"
read -rp "Create branch now? [Y/n] " go
[[ "${go:-Y}" =~ ^[Yy]$ ]] || exit 0

git switch "${BASE_BRANCH}" >/dev/null 2>&1 || git checkout "${BASE_BRANCH}"
git pull --ff-only origin "${BASE_BRANCH}" || true
git switch -c "${BRANCH}"

# Set upstream
if git rev-parse --verify --quiet origin/"${BRANCH}" >/dev/null; then
  git branch --set-upstream-to=origin/"${BRANCH}" >/dev/null
else
  git push -u origin "${BRANCH}"
fi

echo "Created and checked out '${BRANCH}'."
echo "Tip: rebase before PR -> git fetch origin && git rebase origin/${BASE_BRANCH}"
