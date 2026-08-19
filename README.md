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
{ inputs, ... }:
{
  imports = [ inputs.metis.homeManagerModules.default ];

  metis.opencode = {
    enable = true;
    anthropicSkills.enable = false;
    mattPocockSkills.enable = false;
    vercelSkills.enable = false;
  };
}
```

The opencode module installs the superpowers spine and the first-party metis assets whenever `enable` is true. The spine provides the superpowers plugin and skills that drive the whole workflow. The first-party assets are the `commit` and `pull-request` commands, their two supporting skills, and the shared context. Each leaf skill source, anthropic, vercel, and matt-pocock, is an optional add-on gated by its own enable flag and defaulting to off.

The superpowers plugin is an opencode artifact. It registers the skills directory and injects the `using-superpowers` bootstrap into every opencode session, which is what makes the spine load automatically. Claude Code and Codex receive the same skills, agents, commands, and context, but they do not receive the plugin, because no portable equivalent exists. On those targets the superpowers skills are present on disk and available through the native skill loading mechanism, yet there is no automatic session bootstrap. Load the `using-superpowers` skill at the start of a session on Claude Code or Codex to get the same always-on behavior.

The flake also provides `metis.claude` and `metis.codex` modules that mirror `metis.opencode`. For other targets, use the low-level `lib.build` function described below.

## Overview

Metis exposes a home-manager module (`metis.opencode.enable = true`) and a build function through its flake `lib`. The build function discovers the local skills and commands, merges them with pinned upstream sources, and returns an attribute set ready to feed into a home-manager program module.

## Contents

| Path | Description |
| --- | --- |
| `core/commands/` | The `commit` and `pull-request` slash commands. |
| `core/skills/` | The `git-commit` and `github-pull-request` skills. |
| `context.md` | Shared global instructions rendered to `AGENTS.md` or `CLAUDE.md`. |

## Function Reference

`lib.build` accepts these arguments.

| Argument | Description |
| --- | --- |
| `pkgs` | The nixpkgs instance for the target system. |

The function returns an attribute set with these members.

| Attribute | Description |
| --- | --- |
| `anthropicSkills` | The discovered Anthropic leaf skills. |
| `anthropicSkillsSrc` | The Anthropic skills source. |
| `commands` | The first-party metis commands. |
| `context` | The path to `context.md`. |
| `coreSkills` | The discovered first-party metis skills. |
| `mattPocockSkills` | The discovered Matt Pocock engineering skills. |
| `mattPocockSkillsSrc` | The Matt Pocock skills source. |
| `packages` | The list of companion command line packages. |
| `superpowersPlugin` | The path to the superpowers opencode plugin. |
| `superpowersSkills` | The discovered upstream superpowers skills. |
| `superpowersSrc` | The superpowers source. |
| `vercelSkills` | The discovered Vercel leaf skills. |
| `vercelSkillsSrc` | The Vercel skills source. |

## Upstream Sources

Metis bundles skills from these projects, pinned through flake inputs.

- [obra/superpowers][superpowers]
- [anthropics/skills][anthropic-skills]
- [vercel-labs/skills][vercel-skills]
- [mattpocock/skills][matt-pocock-skills]

## Deployment Without Home Manager

The deployment script installs the rendered Metis tree for people who do not use Home Manager. It requires Docker because it runs `scripts/dump.sh` to refresh `generated/` before copying files.

Pass the target tool to the script.

```console
scripts/deploy.sh claude
scripts/deploy.sh codex
scripts/deploy.sh opencode
```

The script deploys to the standard configuration directory for each tool.

| Tool | Target Directory |
| --- | --- |
| Claude Code | `~/.claude` |
| Codex | `~/.codex` |
| opencode | `~/.config/opencode` |

Each deployment replaces the tool's Metis managed context file and directories. Unrelated files already in the target directory, such as `opencode.jsonc`, remain untouched.

## Development

- Run `nix flake check` to evaluate the flake.
- Run `nix fmt` to format Nix files.
- Run `pre-commit run --all-files` before committing.

These scripts run the checks inside a Nix container and require only Docker.

- Run `scripts/test.sh` to evaluate the flake with `nix flake check`.
- Run `scripts/format-check.sh` to confirm the Nix files are formatted.
- Run `scripts/dump.sh` to list the generated attribute names and store paths, and to materialize the rendered tree into `generated/`.

## License

Metis is released under the [MIT License][license]. Bundled upstream skills retain their own licenses.

[anthropic-skills]: https://github.com/anthropics/skills
[home-manager]: https://github.com/nix-community/home-manager
[license]: ./LICENSE
[matt-pocock-skills]: https://github.com/mattpocock/skills
[superpowers]: https://github.com/obra/superpowers
[vercel-skills]: https://github.com/vercel-labs/skills
