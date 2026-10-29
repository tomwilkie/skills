---
name: clean
description: Tidy a git checkout at the end of a session. Removes the worktrees and local branches whose pull requests have merged, checks out and fast-forwards the default branch, and reports uncommitted changes, unpushed commits and branches with open pull requests. Use when the user runs /clean or asks to clean up merged branches or worktrees after finishing work.
argument-hint: "[--yes]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/clean.sh), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/clean.sh *)
---

# Clean up after a session

Everything that touches the repository goes through one script. Do not run
`git branch -D`, `git worktree remove`, `git checkout`, `git pull` or anything
with `--force` yourself, and never stash, commit or push on the user's behalf.
The script decides what is safe; your job is to run it, relay what it says, and
get the user's go-ahead before it deletes anything.

## 1. Plan

Run the script with no arguments:

```
${CLAUDE_PLUGIN_ROOT}/scripts/clean.sh
```

It fetches, then prints a plan without changing anything. Each branch is marked
`keep` or `delete`. A branch is only `delete` when its pull request has merged,
or when it has no pull request and every commit is already on the default
branch. Each action is printed as `would: ...` or `skip: ...`.

If the script exits non-zero, show the user its error and stop.

## 2. Report

Tell the user, in a few lines of prose:

- which worktrees have uncommitted or untracked files
- which branches have unpushed commits or no pull request
- which branches have open pull requests
- what would be removed, by branch name and worktree path
- anything the script will skip, and why

Leave out things that are clean or up to date unless there is nothing else to say.

## 3. Apply

If the plan has no `would: remove worktree` and no `would: delete branch`
lines, run it again with `--apply` straight away. The only changes are to the
default branch, and the script refuses to fast-forward over local work.

Otherwise ask the user to confirm the removals, unless `$ARGUMENTS` contains
`--yes`. Then run:

```
${CLAUDE_PLUGIN_ROOT}/scripts/clean.sh --apply
```

## 4. Close out

Relay the `done`, `skip` and `FAILED` lines. Quote the output of any failure
verbatim. If the script prints a `Note` saying the directory it ran from was
removed, tell the user to change to the main worktree it names; your own shell
is in a directory that no longer exists too, so pass the main worktree path to
any further git commands with `git -C`.
