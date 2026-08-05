# Metis

Metis packages LLM skills, commands, and agents as a [home-manager][home-manager] consumable Nix flake. The name honors Metis, the Greek titaness of wisdom and skill.

## Quick Start

Add Metis to your flake inputs.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    metis.url = "github:madsjoh/metis";
  };
}
```

Wire the returned settings into a home-manager module.

```nix
# home.nix
{
  metis.opencode = {
    enable = true;
    anthropicSkills.enable = false;
    mattPocockSkills.enable = false;
    vercelSkills.enable = false;
    core.models.primary = "opencode/gpt-5.1-codex";
  };
}
```

The opencode module installs the superpowers spine and the first-party metis assets whenever `enable` is true. The spine provides the superpowers plugin and skills that drive the whole workflow. The first-party assets are the `builder` agent, the `commit` and `pull-request` commands, their two supporting skills, and the shared context. Each leaf skill source, anthropic, vercel, and matt-pocock, is an optional add-on gated by its own enable flag and defaulting to off. Model configuration for the builder agent lives under `core.models.primary`.

Or use the low-level builder.

```nix
# home.nix
{ pkgs, inputs, ... }:
let
  settings = inputs.metis.lib.build { inherit pkgs; };
in
{
  programs.claude-code = {
    enable = true;
    agents = settings.agents;
    commands = settings.commands;
    context = settings.context;
    skills = settings.superpowersSkills // settings.coreSkills;
    # Optional: layer in leaf sources, for example:
    # // settings.anthropicSkills // settings.vercelSkills // settings.mattPocockSkills;
  };
}
```

The same settings apply to `opencode`, which reads the identical attribute set.

## Overview

Metis exposes a home-manager module (`metis.opencode.enable = true`) and a builder function through its flake `lib`. The builder discovers the local skills, commands, and agents, merges them with pinned upstream sources, and returns an attribute set ready to feed into a home-manager program module.

## Contents

| Path | Description |
| --- | --- |
| `core/agents/` | The first-party `builder` agent. |
| `core/commands/` | The `commit` and `pull-request` slash commands. |
| `core/skills/` | The `upsert-git-commit` and `upsert-github-pull-request` skills. |
| `context.md` | Shared global instructions rendered to `AGENTS.md` or `CLAUDE.md`. |

## Function Reference

`lib.build` accepts these arguments.

| Argument | Description |
| --- | --- |
| `pkgs` | The nixpkgs instance for the target system. |
| `models` | Optional model configuration. Defaults to the pinned primary model. |

The function returns an attribute set with these members.

| Attribute | Description |
| --- | --- |
| `agents` | Local agents merged with the superpowers code reviewer. |
| `commands` | Local commands merged with the superpowers commands. |
| `context` | The path to `context.md`. |
| `coreSkills` | The discovered first-party metis skills. |
| `superpowersSkills` | The discovered upstream superpowers skills. |
| `packages` | The list of companion command line packages. |
| `mattPocockSkills` | The discovered Matt Pocock skills. |
| `anthropicSkills` | The discovered Anthropic leaf skills. |
| `vercelSkills` | The discovered Vercel leaf skills. |
| `anthropicSkillsSrc` | The Anthropic skills source. |
| `superpowersSrc` | The superpowers source. |
| `vercelSkillsSrc` | The Vercel skills source. |

## Upstream Sources

Metis bundles skills from these projects, pinned through flake inputs.

- [obra/superpowers][superpowers]
- [anthropics/skills][anthropic-skills]
- [vercel-labs/skills][vercel-skills]
- [mattpocock/skills][matt-pocock-skills]

## Development

- Run `nix flake check` to evaluate the flake.
- Run `nix fmt` to format Nix files.
- Run `pre-commit run --all-files` before committing.

These scripts run the checks inside a Nix container and require only Docker.

- Run `scripts/test.sh` to evaluate the flake and assert the settings.
- Run `scripts/format-check.sh` to confirm the Nix files are formatted.
- Run `scripts/dump.sh` to list the generated attribute names and store paths, and to materialize the rendered tree into `generated/`.

## License

Metis is released under the [MIT License](./LICENSE). Bundled upstream skills retain their own licenses.

[anthropic-skills]: https://github.com/anthropics/skills
[home-manager]: https://github.com/nix-community/home-manager
[matt-pocock-skills]: https://github.com/mattpocock/skills
[superpowers]: https://github.com/obra/superpowers
[vercel-skills]: https://github.com/vercel-labs/skills
