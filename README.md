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
{ pkgs, inputs, ... }:
let
  settings = inputs.metis.lib.mkSettings { inherit pkgs; };
in
{
  programs.claude-code = {
    enable = true;
    agents = settings.agents;
    commands = settings.commands;
    context = settings.context;
    skills = settings.skills;
  };
}
```

The same settings apply to `programs.opencode`, which reads the identical attribute set.

## Overview

Metis exposes a single builder function through its flake `lib`. The function discovers the local skills, commands, and agents, merges them with pinned upstream sources, and returns an attribute set ready to feed into a home-manager program module.

## Contents

| Path | Description |
| --- | --- |
| `skills/` | Directory skills in `SKILL.md` format. |
| `commands/` | Slash command definitions. |
| `agents/` | Agent definitions. |
| `context.md` | Shared global instructions rendered to `AGENTS.md` or `CLAUDE.md`. |

## Function Reference

`mkSettings` accepts these arguments.

| Argument | Description |
| --- | --- |
| `pkgs` | The nixpkgs instance for the target system. |
| `mattPocockSkillsSource` | Optional override for the Matt Pocock skills source. Defaults to the pinned flake input. |

The function returns an attribute set with these members.

| Attribute | Description |
| --- | --- |
| `agents` | Local agents merged with the superpowers code reviewer. |
| `commands` | Local commands merged with the superpowers commands. |
| `context` | The path to `context.md`. |
| `skills` | Local skills merged with the Matt Pocock skills. |
| `packages` | The list of companion command line packages. |
| `mattPocockSkills` | The discovered Matt Pocock skills. |
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
