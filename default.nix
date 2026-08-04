{
  pkgs,
  basePath,
  sources,
  mattPocockSkillsSource ? sources.matt-pocock-skills,
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

  # mattpocock/skills: Skills for real software engineering.
  # https://github.com/mattpocock/skills
  mattPocockSkills =
    discoverDirectorySkills (mattPocockSkillsSource + "/skills/engineering")
    // discoverDirectorySkills (mattPocockSkillsSource + "/skills/productivity");

  # vercel-labs/skills: Open agent skills ecosystem.
  # https://github.com/vercel-labs/skills
  vercelSkillsSrc = sources.vercel-skills;
in
{
  inherit anthropicSkillsSrc;
  inherit mattPocockSkills;
  inherit superpowersSrc;
  inherit vercelSkillsSrc;

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
      agentsDir = basePath + "/agents";
    in
    pkgs.lib.mapAttrs'
      (name: _: pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".md" name) (agentsDir + "/${name}"))
      (
        pkgs.lib.filterAttrs (name: type: type == "regular" && pkgs.lib.hasSuffix ".md" name) (
          builtins.readDir agentsDir
        )
      )
    // {
      superpowers-code-reviewer = "${superpowersSrc}/agents/code-reviewer.md";
    };

  commands =
    let
      commandsDir = basePath + "/commands";
    in
    pkgs.lib.mapAttrs'
      (name: _: pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".md" name) (commandsDir + "/${name}"))
      (
        pkgs.lib.filterAttrs (name: type: type == "regular" && pkgs.lib.hasSuffix ".md" name) (
          builtins.readDir commandsDir
        )
      )
    // {
      brainstorm = "${superpowersSrc}/commands/brainstorm.md";
      execute-plan = "${superpowersSrc}/commands/execute-plan.md";
      write-plan = "${superpowersSrc}/commands/write-plan.md";
    };

  skills =
    let
      skillsDir = basePath + "/skills";
      localSkills =
        # Auto-discover both flat single-file skills (`<name>.md`) and directory
        # skills (`<name>/SKILL.md` plus optional `references/` for progressive
        # disclosure). The home-manager module renders a file to `<name>/SKILL.md`
        # and copies a directory recursively.
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
    in
    mattPocockSkills // localSkills;
}
