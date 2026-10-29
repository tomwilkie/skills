# Skills

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) of skills
shared across projects.

| Plugin                             | What it does                                                                                            |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [`docs-style`](plugins/docs-style) | House style for project prose: Google's developer documentation style guide, adapted to British English |
| [`clean`](plugins/clean)           | `/clean` after a session: removes worktrees and branches whose PRs have merged, updates the default branch, and reports what is still outstanding |

## Install a plugin

To use a plugin in one session, add the marketplace and install it:

```sh
/plugin marketplace add tomwilkie/skills
/plugin install docs-style@tomwilkie-skills
```

To have every checkout of a project pick it up, commit this to the project's
`.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "tomwilkie-skills": {
      "source": { "source": "github", "repo": "tomwilkie/skills" }
    }
  },
  "enabledPlugins": {
    "docs-style@tomwilkie-skills": true
  }
}
```

Claude Code asks to trust the marketplace the first time it opens the project.

## Add a plugin

Each plugin lives in `plugins/<name>/`, with a manifest at `.claude-plugin/plugin.json` and its
skills under `skills/<skill>/SKILL.md`. List it in `.claude-plugin/marketplace.json`, then run:

```sh
claude plugin validate .
```
