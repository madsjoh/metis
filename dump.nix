{
  pkgs,
  settings,
  includeAnthropicSkills ? false,
  includeMattPocockSkills ? false,
  includeVercelSkills ? false,
}:
let
  inherit (pkgs) lib;

  substituteModelPlaceholders =
    content:
    builtins.replaceStrings
      [ "__PRIMARY_MODEL__" ]
      [ settings.models.primary ]
      content;

  # Render a single skill entry. A directory skill is copied recursively. A
  # file skill is rendered to `<name>/SKILL.md`.
  renderSkill =
    name: source:
    let
      sourcePath = builtins.toString source;
      isDirectory = (builtins.readFileType source) == "directory";
    in
    if isDirectory then
      "cp --recursive ${sourcePath} \"$out/skills/${name}\""
    else
      ''
        mkdir --parents "$out/skills/${name}"
        cp ${sourcePath} "$out/skills/${name}/SKILL.md"
      '';

  # Render a file entry to `<directory>/<name>.md` with model placeholder substitution.
  renderFile =
    directory: name: source:
    let
      content = builtins.readFile source;
      substituted = substituteModelPlaceholders content;
      storePath = pkgs.writeText "${name}.md" substituted;
    in
    "cp ${storePath} \"$out/${directory}/${name}.md\"";

  superpowersSkillCommands = lib.mapAttrsToList renderSkill settings.superpowersSkills;
  coreSkillCommands = lib.mapAttrsToList renderSkill settings.coreSkills;
  anthropicSkillCommands = lib.optionals includeAnthropicSkills (
    lib.mapAttrsToList renderSkill settings.anthropicSkills
  );
  vercelSkillCommands = lib.optionals includeVercelSkills (
    lib.mapAttrsToList renderSkill settings.vercelSkills
  );
  mattPocockSkillCommands = lib.optionals includeMattPocockSkills (
    lib.mapAttrsToList renderSkill settings.mattPocockSkills
  );
  agentCommands = lib.mapAttrsToList (renderFile "agents") settings.agents;
  commandCommands = lib.mapAttrsToList (renderFile "commands") settings.commands;

  contextCommand = ''cp ${builtins.toString settings.context} "$out/context.md"'';

  pluginCommand = ''cp ${builtins.toString settings.superpowersPlugin} "$out/plugins/superpowers.js"'';
in
pkgs.runCommand "metis-generated" { } ''
  mkdir --parents "$out/skills" "$out/agents" "$out/commands" "$out/plugins"

  ${contextCommand}

  ${lib.concatStringsSep "\n" superpowersSkillCommands}
  ${lib.concatStringsSep "\n" coreSkillCommands}
  ${lib.concatStringsSep "\n" anthropicSkillCommands}
  ${lib.concatStringsSep "\n" vercelSkillCommands}
  ${lib.concatStringsSep "\n" mattPocockSkillCommands}
  ${lib.concatStringsSep "\n" agentCommands}
  ${lib.concatStringsSep "\n" commandCommands}

  ${pluginCommand}

  chmod --recursive u+w "$out"
''
