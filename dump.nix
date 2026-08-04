{
  pkgs,
  settings,
}:
let
  inherit (pkgs) lib;

  substituteModelPlaceholders =
    content:
    builtins.replaceStrings
      [ "__PRIMARY_MODEL__" "__REVIEW_MODEL__" "__LIGHTWEIGHT_MODEL__" ]
      [
        settings.models.primary
        settings.models.review
        settings.models.lightweight
      ]
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

  skillCommands = lib.mapAttrsToList renderSkill settings.skills;
  agentCommands = lib.mapAttrsToList (renderFile "agents") settings.agents;
  commandCommands = lib.mapAttrsToList (renderFile "commands") settings.commands;
in
pkgs.runCommand "metis-generated" { } ''
  mkdir --parents "$out/skills" "$out/agents" "$out/commands" "$out/plugins"

  cp ${builtins.toString settings.context} "$out/context.md"

  ${lib.concatStringsSep "\n" skillCommands}
  ${lib.concatStringsSep "\n" agentCommands}
  ${lib.concatStringsSep "\n" commandCommands}

  cp ${builtins.toString settings.superpowersPlugin} "$out/plugins/superpowers.js"

  chmod --recursive u+w "$out"
''
