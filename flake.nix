{
  description = "LLM skills, commands, and agents packaged as a home-manager consumable Nix flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    # obra/superpowers: A complete software development workflow for coding agents.
    # https://github.com/obra/superpowers
    superpowers = {
      url = "github:obra/superpowers/v6.2.0";
      flake = false;
    };

    # anthropics/skills: Skills for Claude.
    # https://github.com/anthropics/skills
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    # vercel-labs/skills: Open agent skills ecosystem.
    # https://github.com/vercel-labs/skills
    vercel-skills = {
      url = "github:vercel-labs/skills/v1.4.1";
      flake = false;
    };

    # mattpocock/skills: Skills for real software engineering.
    # https://github.com/mattpocock/skills
    matt-pocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      superpowers,
      anthropic-skills,
      vercel-skills,
      matt-pocock-skills,
    }:
    let
      sources = {
        inherit
          superpowers
          anthropic-skills
          vercel-skills
          matt-pocock-skills
          ;
      };

      build =
        { pkgs }:
        import ./default.nix {
          inherit pkgs sources;
          basePath = self;
        };
    in
    {
      lib.build = build;

      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.metis;
          settings = build { inherit pkgs; };

          skillDescriptions = {
            anthropic = "install the anthropic leaf skills on top of the superpowers spine";
            mattpocock = "install the mattpocock leaf skills on top of the superpowers spine";
            vercel = "install the vercel leaf skills on top of the superpowers spine";
          };

          targets = {
            opencode = {
              description = "opencode";
              directory = ".config/opencode";
              contextFile = "AGENTS.md";
              plugins = true;
            };
            claude = {
              description = "Claude Code";
              directory = ".claude";
              contextFile = "CLAUDE.md";
              plugins = false;
            };
            codex = {
              description = "Codex";
              directory = ".codex";
              contextFile = "AGENTS.md";
              plugins = false;
            };
          };

          render =
            name:
            pkgs.callPackage ./dump.nix {
              inherit pkgs settings;
              includeAnthropicSkills = cfg.${name}.skills.anthropic.enable;
              includeMattPocockSkills = cfg.${name}.skills.mattpocock.enable;
              includeVercelSkills = cfg.${name}.skills.vercel.enable;
            };

          homeFiles =
            name: target:
            let
              rendered = render name;
              directory = target.directory;
            in
            {
              "${directory}/${target.contextFile}".source = "${rendered}/context.md";
              "${directory}/agents".source = "${rendered}/agents";
              "${directory}/commands".source = "${rendered}/commands";
              "${directory}/skills".source = "${rendered}/skills";
            }
            // lib.optionalAttrs target.plugins {
              "${directory}/plugins".source = "${rendered}/plugins";
            };
        in
        {
          options.metis = lib.mapAttrs (
            name: target:
            {
              enable = lib.mkEnableOption "configure ${target.description} with metis skills, agents, and commands";
              skills = lib.mapAttrs (skill: description: {
                enable = lib.mkEnableOption description;
              }) skillDescriptions;
            }
            // lib.optionalAttrs (name == "opencode") {
              config = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "opencode configuration rendered to opencode.json; must be serializable as JSON";
              };
            }
          ) targets;

          config = lib.mkMerge (
            lib.mapAttrsToList (
              name: target: lib.mkIf cfg.${name}.enable { home.file = homeFiles name target; }
            ) targets
            ++ [
              (lib.mkIf (cfg.opencode.enable && cfg.opencode.config != { }) {
                home.file.".config/opencode/opencode.json".text = builtins.toJSON (
                  { "$schema" = "https://opencode.ai/config.json"; } // cfg.opencode.config
                );
              })
              (lib.mkIf (cfg.opencode.enable && (cfg.opencode.config.lsp or false) != false) {
                home.packages = settings.lspPackages;
              })
            ]
          );
        };
    }
    # nixpkgs-unstable has dropped x86_64-darwin, so it is excluded here.
    //
      flake-utils.lib.eachSystem
        [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ]
        (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            settings = build { inherit pkgs; };
          in
          {
            # Bundle the tool packages so `nix build` and `nix flake check` have a
            # concrete derivation to evaluate.
            packages.default = pkgs.symlinkJoin {
              name = "metis-packages";
              paths = settings.packages;
            };

            formatter = pkgs.nixfmt-tree;
          }
        );
}
