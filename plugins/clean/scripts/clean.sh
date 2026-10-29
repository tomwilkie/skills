#!/usr/bin/env bash
#
# clean.sh: tidy a git checkout at the end of a session.
#
#   clean.sh           report what would change and touch nothing but the
#                      remote-tracking refs (it fetches)
#   clean.sh --apply   fetch, update the default branch, then remove the
#                      worktrees and local branches whose pull requests merged
#
# It never deletes a branch that has an open pull request, a pull request that
# was closed without merging, or no pull request and unmerged commits. It never
# removes a worktree with uncommitted or untracked files.

set -euo pipefail

apply=0
case "${1:-}" in
  "") ;;
  --apply) apply=1 ;;
  -h|--help) sed -n '3,12p' "$0"; exit 0 ;;
  *) echo "clean.sh: unknown argument: $1" >&2; exit 2 ;;
esac

die()     { echo "clean.sh: $*" >&2; exit 1; }
heading() { printf '\n== %s\n' "$*"; }
item()    { printf '  %s\n' "$*"; }

# run <description> <command...>: print the plan, or do it and report.
run() {
  local desc=$1 out; shift
  if [ "$apply" = 1 ]; then
    if out=$("$@" 2>&1); then
      item "done: $desc"
    else
      item "FAILED: $desc"
      printf '%s\n' "$out" | sed 's/^/        /'
      return 1
    fi
  else
    item "would: $desc"
  fi
}

dirty() { [ -n "$(git -C "$1" status --porcelain 2>/dev/null)" ]; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not inside a git worktree"
invoked_from=$PWD

remote=origin
git remote get-url "$remote" >/dev/null 2>&1 || die "no remote named $remote"

# Branches and worktrees are repository-wide, so work from the main worktree.
main_wt=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
cd "$main_wt"

have_gh=0
if command -v gh >/dev/null 2>&1 && gh repo view --json name >/dev/null 2>&1; then
  have_gh=1
fi

# --- Repository ---------------------------------------------------------------

heading "Repository"
item "main worktree: $main_wt"
[ "$apply" = 1 ] && item "mode: apply" || item "mode: plan (nothing changes; run with --apply to do it)"

if git fetch --prune --quiet "$remote" 2>/dev/null; then
  item "fetched $remote and pruned stale remote-tracking branches"
else
  item "WARNING: fetch from $remote failed; using the last fetched state"
fi

default=$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null | sed "s|^$remote/||" || true)
if [ -z "$default" ]; then
  git remote set-head "$remote" --auto >/dev/null 2>&1 || true
  default=$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null | sed "s|^$remote/||" || true)
fi
if [ -z "$default" ] && [ "$have_gh" = 1 ]; then
  default=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null || true)
fi
if [ -z "$default" ]; then
  for candidate in main master; do
    if git show-ref --verify --quiet "refs/remotes/$remote/$candidate"; then default=$candidate; break; fi
  done
fi
[ -n "$default" ] || die "could not determine the default branch of $remote"
git show-ref --verify --quiet "refs/remotes/$remote/$default" || die "$remote/$default is not present locally"
item "default branch: $default"
if [ "$have_gh" = 1 ]; then
  item "pull request state: from GitHub via gh"
else
  item "pull request state: unavailable (gh missing, not logged in, or not a GitHub remote); only branches fully merged into $default are candidates"
fi

# --- Worktrees ------------------------------------------------------------------

wt_paths=()
wt_branches=()
while IFS=$'\t' read -r p b; do
  wt_paths+=("$p")
  wt_branches+=("$b")
done < <(git worktree list --porcelain | awk '
  /^worktree /  { path = substr($0, 10) }
  /^branch /    { branch = substr($0, 8); sub("^refs/heads/", "", branch) }
  /^detached$/  { branch = "(detached)" }
  /^$/          { if (path != "") print path "\t" branch; path = ""; branch = "" }
  END           { if (path != "") print path "\t" branch }')

worktree_for() {
  local i
  for ((i = 0; i < ${#wt_paths[@]}; i++)); do
    if [ "${wt_branches[$i]}" = "$1" ]; then printf '%s' "${wt_paths[$i]}"; return; fi
  done
}

heading "Worktrees"
for ((i = 0; i < ${#wt_paths[@]}; i++)); do
  p=${wt_paths[$i]}
  if dirty "$p"; then
    n=$(git -C "$p" status --porcelain | wc -l | tr -d ' ')
    item "$p  [${wt_branches[$i]}]  $n uncommitted or untracked file(s)"
  else
    item "$p  [${wt_branches[$i]}]  clean"
  fi
done

# --- Branches -------------------------------------------------------------------

heading "Branches"
delete_branches=()
delete_reasons=()
while IFS= read -r b; do
  [ "$b" = "$default" ] && continue

  pr=""
  if [ "$have_gh" = 1 ]; then
    # Prefer an open PR over a merged one over a closed one, so a branch that
    # was reused for new work is never deleted on the strength of an old merge.
    pr=$(gh pr list --head "$b" --state all --limit 20 --json state,number,url \
          --jq 'map(select(.state=="OPEN")) + map(select(.state=="MERGED")) + map(select(.state=="CLOSED"))
                | .[0] | select(.) | "\(.state) #\(.number) \(.url)"' 2>/dev/null || true)
  fi
  pr_state=${pr%% *}

  merged_in_git=0
  git merge-base --is-ancestor "$b" "$remote/$default" 2>/dev/null && merged_in_git=1

  if git rev-parse --verify --quiet "$b@{upstream}" >/dev/null 2>&1; then
    ahead=$(git rev-list --count "$b@{upstream}..$b")
    sync="$ahead unpushed commit(s)"
  else
    ahead=$(git rev-list --count "$remote/$default..$b")
    sync="no upstream, $ahead commit(s) not on $default"
  fi

  case "$pr_state" in
    OPEN)   item "keep   $b  open PR $pr  ($sync)" ;;
    MERGED) delete_branches+=("$b"); delete_reasons+=("PR merged, $pr")
            item "delete $b  merged PR $pr" ;;
    CLOSED) item "keep   $b  PR closed without merging $pr  ($sync)" ;;
    *)      if [ "$merged_in_git" = 1 ]; then
              delete_branches+=("$b"); delete_reasons+=("fully merged into $default")
              item "delete $b  fully merged into $default, no PR found"
            else
              item "keep   $b  no PR  ($sync)"
            fi ;;
  esac
done < <(git for-each-ref --format='%(refname:short)' refs/heads/)
[ "${#delete_branches[@]}" = 0 ] && item "(no branches to delete)"

# --- Default branch -------------------------------------------------------------

heading "Default branch"
default_wt=$(worktree_for "$default")
if [ -z "$default_wt" ]; then
  main_branch=${wt_branches[0]}
  if dirty "$main_wt"; then
    item "skip: main worktree is on $main_branch with uncommitted changes, so not switching to $default"
  elif run "switch main worktree from $main_branch to $default" git -C "$main_wt" checkout --quiet "$default"; then
    default_wt=$main_wt
    wt_branches[0]=$default
  fi
fi
if [ -n "$default_wt" ]; then
  if git show-ref --verify --quiet "refs/heads/$default"; then
    ahead=$(git rev-list --count "$remote/$default..$default")
    behind=$(git rev-list --count "$default..$remote/$default")
  else
    ahead=0; behind=0   # checkout above will create it from $remote/$default
  fi
  if [ "$ahead" != 0 ]; then
    item "WARNING: $default has $ahead local commit(s) not on $remote/$default"
  fi
  if [ "$behind" = 0 ]; then
    item "$default is up to date with $remote/$default"
  else
    run "fast-forward $default by $behind commit(s) in $default_wt" git -C "$default_wt" merge --ff-only --quiet "$remote/$default" || true
  fi
fi

# --- Removals -------------------------------------------------------------------

heading "Removals"
removed=0
for ((i = 0; i < ${#delete_branches[@]}; i++)); do
  b=${delete_branches[$i]}
  wt=$(worktree_for "$b")
  if [ -n "$wt" ]; then
    if [ "$wt" = "$main_wt" ]; then
      item "skip: $b is still checked out in the main worktree"
      continue
    fi
    if dirty "$wt"; then
      item "skip: worktree $wt on $b has uncommitted or untracked files"
      continue
    fi
    run "remove worktree $wt  [$b]" git worktree remove "$wt" || continue
  fi
  run "delete branch $b  (${delete_reasons[$i]})" git branch -D "$b" && removed=$((removed + 1))
done
[ "$removed" = 0 ] && [ "${#delete_branches[@]}" = 0 ] && item "(nothing to remove)"
run "prune worktree metadata" git worktree prune

if [ "$apply" = 1 ] && [ ! -d "$invoked_from" ]; then
  heading "Note"
  item "the directory this ran from was removed: $invoked_from"
  item "change to the main worktree: $main_wt"
fi
