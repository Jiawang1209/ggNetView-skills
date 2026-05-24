# ggNetView-skills

A Claude Code **plugin** (and self-contained **marketplace**) that bundles a skill for
using the [ggNetView](https://github.com/Jiawang1209) R package — a reproducible,
deterministic framework for analyzing and visualizing biological, ecological, and
microbial association networks (built on `ggplot2`, `ggraph`, and `tidygraph`).

The skill teaches an AI agent to: write correct ggNetView plotting code, look up the
API, follow typical analysis workflows, and troubleshoot common errors.

## Repository layout

```
ggNetView-skills/
├── .claude-plugin/
│   ├── plugin.json          # marks this repo as a plugin
│   └── marketplace.json     # marks this repo as a marketplace (lists the plugin)
├── skills/
│   └── ggnetview/
│       ├── SKILL.md         # lean entry point (when-to-use, quick reference)
│       ├── api-reference.md # (planned) function/parameter reference
│       ├── workflows.md     # (planned) end-to-end scenarios
│       ├── troubleshooting.md # (planned) common errors + fixes
│       └── examples/        # (planned) runnable .R scripts + sample data
└── sources/                 # local-only build inputs (git-ignored)
    ├── package/ggNetView/   # R package source
    └── manual/ggNetView-manual/  # bookdown manual (10 chapters)
```

`sources/` is **git-ignored**: it is the raw material used to distill the skill, not
part of the shipped plugin.

## Install

As a user (from GitHub):

```
/plugin marketplace add Jiawang1209/ggNetView-skills
/plugin install ggnetview-skills@ggnetview-marketplace
```

For local development / self-use:

```
claude --plugin-dir ./
```

Then the skill is available as `/ggnetview-skills:ggnetview`.

## Status & authoring roadmap

The skill is **scaffolded but not yet authored**. It is being built with the
`superpowers:writing-skills` TDD method:

1. **RED — baseline test.** Ask an agent (without this skill) to write ggNetView code
   for representative tasks. Record verbatim what it gets wrong (invented functions,
   wrong parameters, missing steps).
2. **GREEN — write the skill.** Author `SKILL.md` + reference files that fix exactly
   those failures (not a re-dump of the manual).
3. **REFACTOR — re-test.** Repeat until an agent reliably writes correct code.

## License

GPL (>= 3), matching the ggNetView package.
