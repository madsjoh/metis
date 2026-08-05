# Superpowers Spine With Two Metis Commands

## Problem

Metis currently bundles two competing workflow philosophies. The first-party "core" system ships its own end-to-end workflow through seven agents (`builder`, `planner`, `code-reviewer`, `security-auditor`, `technical-writer`, `explorer`, `chicken`) and seven commands (`plan`, `implement`, `commit`, `pull-request`, `research`, `fix-issue`, `changelog`). At the same time, the superpowers source ships its own full workflow: a plugin that injects a bootstrap into every session plus process skills such as `brainstorming`, `writing-plans`, `executing-plans`, `requesting-code-review`, and `systematic-debugging`.

Superpowers is not a leaf skill library. It is a workflow spine, opinionated about the whole lifecycle. Running it alongside the first-party workflow produces two planners, two reviewers, and a session plugin that overrides behavior regardless of the core agents. The incoherence comes from importing a whole opinionated workflow alongside a competing one.

## Decision

Adopt superpowers as the single workflow spine. Keep only the two metis commands that superpowers has no equivalent for, `commit` and `pull-request`, and have them ride on the spine through the surviving `builder` agent and two supporting skills.

## Terminology

- **Spine.** A source that defines how work flows end to end: brainstorm, plan, implement, review, verify. Superpowers is the spine.
- **Leaf source.** A capability library providing individual, self-contained abilities with no opinion about the overall workflow. Anthropic, Vercel, and Matt Pocock are leaf sources.

## Source Model

- The superpowers spine (plugin plus its skills) is mandatory whenever `metis.opencode.enable = true`. It is no longer gated behind a toggle.
- Each leaf source (anthropic, vercel, matt-pocock) is individually optional through its own enable flag, defaulting to off. Zero leaf sources is allowed.

## Component Changes

### Agents (keep 1 of 7)

- Keep `builder.md`. Rewire it: remove the references to the deleted `apply-writing-style` skill and the deleted `planner`, `security-auditor`, and `technical-writer` handoffs. Style enforcement now comes from `context.md` globally.
- Delete `planner.md`, `code-reviewer.md`, `security-auditor.md`, `technical-writer.md`, `explorer.md`, and `chicken.md`. Their roles are covered by the superpowers skills (`writing-plans`, `requesting-code-review`, `systematic-debugging`, `verification-before-completion`) plus opencode's built-in `general` and `explore` agents.

### Commands (keep 2 of 7)

- Keep `commit.md` and `pull-request.md`. Both retain `agent: builder`.
- Delete `plan.md`, `implement.md`, `research.md`, `fix-issue.md`, and `changelog.md`.

### Skills (keep 2 of 6)

- Keep `upsert-git-commit/` and `upsert-github-pull-request/`. Strip the `apply-writing-style` load line from each `SKILL.md`, since style is enforced globally through `context.md`.
- Delete `apply-writing-style/`, `apply-owasp-security/`, `fix-github-issue/`, and `upsert-github-release/`.

## Nix Module Changes

### Model configuration

Only `builder` remains, and it uses `__PRIMARY_MODEL__` only. Simplify the `models` submodule to a single `primary` field. Reduce the `dump.nix` substitution to `__PRIMARY_MODEL__` alone, dropping `__REVIEW_MODEL__` and `__LIGHTWEIGHT_MODEL__`.

### flake.nix

- Keep the superpowers input. Keep the three leaf source inputs.
- Replace the `superpowers.enable` and `core.enable` gates. The spine and the core assets (two commands, builder, two skills, context) always ship when `metis.opencode.enable = true`.
- Add per-source enable options for anthropic, vercel, and matt-pocock leaf sources, each optional and defaulting to off.
- Simplify `core.models` to a single `primary` field.

### default.nix

- Agent, command, and core skill auto-discovery stays as is; it handles the reduced set.
- Always emit the superpowers plugin and `superpowersSkills`.
- Add discovery for `anthropicSkills`, `vercelSkills`, and `mattPocockSkills`, gated in the module by their flags.

### dump.nix

- Replace `includeSuperpowers` and `includeCore` with the leaf source flags.
- Always render the superpowers plugin, the core commands, the builder agent, the two core skills, and `context.md`.
- Reduce the model placeholder substitution to `__PRIMARY_MODEL__`.

## Documentation

- Rewrite the README Quick Start and source table to reflect the mandatory spine and optional leaf sources.
- Remove the "two independent feature groups" language, since superpowers is no longer a toggle.

## Testing

- Run `nix flake check` to evaluate the flake.
- Run `nix fmt` to format the Nix files.
- Run `scripts/dump.sh` to materialize the rendered tree into `generated/` and confirm the reduced set of agents, commands, and skills appears, that the superpowers plugin is present, and that leaf source skills appear only when their flags are enabled.
