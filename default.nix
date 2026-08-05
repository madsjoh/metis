{
  pkgs,
  basePath,
  sources,
  models ? {
    primary = "opencode/gpt-5.1-codex";
    review = "opencode/gpt-5.1-codex";
    lightweight = "opencode/gpt-5.1-codex";
  },
}:
let
  discoverDirectorySkills =
    skillsDir:
    pkgs.lib.mapAttrs' (name: _: pkgs.lib.nameValuePair name (skillsDir + "/${name}")) (
      pkgs.lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists (skillsDir + "/${name}/SKILL.md")
      ) (builtins.readDir skillsDir)
    );

  # obra/superpowers: A complete software development workflow for coding agents.
  # https://github.com/obra/superpowers
  superpowersSrc = sources.superpowers;

  # anthropics/skills: Skills for Claude.
  # https://github.com/anthropics/skills
  anthropicSkillsSrc = sources.anthropic-skills;

  # vercel-labs/skills: Open agent skills ecosystem.
  # https://github.com/vercel-labs/skills
  vercelSkillsSrc = sources.vercel-skills;
in
{
  inherit anthropicSkillsSrc;
  inherit superpowersSrc;
  inherit vercelSkillsSrc;

  inherit models;

  # The superpowers plugin automatically registers the skills directory and injects the
  # using-superpowers bootstrap with tool mapping into every session.
  superpowersPlugin = superpowersSrc + "/.opencode/plugins/superpowers.js";

  # Shared global instructions rendered to each agent's user level rules file.
  # opencode renders this to AGENTS.md and claude-code renders it to CLAUDE.md.
  context = basePath + "/context.md";

  packages =
    with pkgs;
    [
      chatgpt-cli # https://search.nixos.org/packages?channel=unstable&type=packages&show=chatgpt-cli
      codex # https://search.nixos.org/packages?channel=unstable&type=packages&show=codex
      pi-coding-agent # https://search.nixos.org/packages?channel=unstable&type=packages&show=pi-coding-agent
    ]
    ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) [
      chatgpt-desktop # https://search.nixos.org/packages?channel=unstable&type=packages&show=chatgpt-desktop
      codex-bar # https://search.nixos.org/packages?channel=unstable&type=packages&show=codex-bar
    ];

  agents =
    let
      agentsDir = basePath + "/core/agents";
    in
    pkgs.lib.mapAttrs'
      (name: _: pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".md" name) (agentsDir + "/${name}"))
      (
        pkgs.lib.filterAttrs (name: type: type == "regular" && pkgs.lib.hasSuffix ".md" name) (
          builtins.readDir agentsDir
        )
      );

  commands =
    let
      commandsDir = basePath + "/core/commands";
    in
    pkgs.lib.mapAttrs'
      (name: _: pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".md" name) (commandsDir + "/${name}"))
      (
        pkgs.lib.filterAttrs (name: type: type == "regular" && pkgs.lib.hasSuffix ".md" name) (
          builtins.readDir commandsDir
        )
      );

  # Upstream superpowers skills. Gated by the superpowers feature group.
  superpowersSkills = discoverDirectorySkills (superpowersSrc + "/skills");

  # First-party metis skills. Gated by the core feature group.
  #
  # Auto-discover both flat single-file skills (`<name>.md`) and directory
  # skills (`<name>/SKILL.md` plus optional `references/` for progressive
  # disclosure). The home-manager module renders a file to `<name>/SKILL.md`
  # and copies a directory recursively.
  coreSkills =
    let
      skillsDir = basePath + "/core/skills";
    in
    pkgs.lib.mapAttrs'
      (
        name: type:
        if type == "directory" then
          pkgs.lib.nameValuePair name (skillsDir + "/${name}")
        else
          pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".md" name) (skillsDir + "/${name}")
      )
      (
        pkgs.lib.filterAttrs (
          name: type:
          (type == "regular" && pkgs.lib.hasSuffix ".md" name)
          || (type == "directory" && builtins.pathExists (skillsDir + "/${name}/SKILL.md"))
        ) (builtins.readDir skillsDir)
      );
}
