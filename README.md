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
├── AGENTS.md                # cross-tool guidance (Codex etc. — skills don't auto-activate there)
├── skills/
│   └── ggnetview/
│       ├── SKILL.md         # lean entry point (when-to-use, quick reference)
│       ├── api-reference.md # authoritative exported-function list + signatures
│       ├── workflows.md     # 10 end-to-end workflows (6 core + 4 advanced)
│       ├── troubleshooting.md # common errors + fixes
│       └── examples/        # runnable .R scripts (01–10) + figures/
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

## Use it in other tools (Codex, etc.)

Claude Code auto-activates the skill from `skills/ggnetview/SKILL.md` by its
`description`. Other agents (e.g. OpenAI Codex CLI) **do not** auto-activate skills,
but the knowledge is plain markdown and fully portable. `AGENTS.md` at the repo root
carries the same core guidance as always-on context (Codex auto-loads `AGENTS.md`)
and points to the detailed reference files. There is no native marketplace install
for Codex; clone the repo (or copy `AGENTS.md` + `skills/ggnetview/`) and let the
agent read them.

## How it was built (and how to extend it)

The skill follows the `superpowers:writing-skills` TDD method — each addition fixes
observed failures rather than re-dumping the manual:

1. **RED — baseline test.** Ask an agent (without this skill) to write ggNetView code
   for the target task. Record verbatim what it invents (wrong function names,
   parameters, missing steps).
2. **GREEN — write the skill.** Add to `SKILL.md` + the reference files exactly what
   fixes those failures.
3. **REFACTOR — re-test.** Re-run the task with the skill until the agent reliably
   writes correct code.

The skill currently covers **10 workflows**: build/plot, RMT threshold, topology,
layouts, cross-group comparison, WGCNA, plus the advanced set — Zi-Pi keystone &
hub nodes, network–environment Mantel, multi-omics/bipartite, and subgraph/per-sample.

## License

GPL (>= 3), matching the ggNetView package.
