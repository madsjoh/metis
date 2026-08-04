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
        {
          pkgs,
          models ? {
            primary = "opencode/gpt-5.1-codex";
            review = "opencode/gpt-5.1-codex";
            lightweight = "opencode/gpt-5.1-codex";
          },
        }:
        import ./default.nix {
          inherit pkgs sources models;
          basePath = self;
        };
    in
    {
      lib.build = build;

      homeManagerModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.metis;
          defaultModels = {
            primary = "opencode/gpt-5.1-codex";
            review = "opencode/gpt-5.1-codex";
            lightweight = "opencode/gpt-5.1-codex";
          };
          models = defaultModels // (cfg.opencode.models or {});
          rendered = pkgs.callPackage ./dump.nix {
            inherit pkgs;
            settings = build { inherit pkgs models; };
          };
        in
        {
          options.metis.opencode.enable = lib.mkEnableOption "configure opencode with metis skills, agents, and commands";
          options.metis.opencode.models = lib.mkOption {
            type = with lib.types; submodule {
              options = {
                primary = lib.mkOption {
                  type = str;
                  default = "opencode/gpt-5.1-codex";
                  description = "Model for primary agents (builder, planner).";
                };
                review = lib.mkOption {
                  type = str;
                  default = "opencode/gpt-5.1-codex";
                  description = "Model for review agents (code-reviewer, security-auditor, technical-writer).";
                };
                lightweight = lib.mkOption {
                  type = str;
                  default = "opencode/gpt-5.1-codex";
                  description = "Model for lightweight agents (chicken, explorer).";
                };
              };
            };
            default = {};
            description = "Model configuration for Metis agents.";
          };
          options.metis.claude.enable = lib.mkEnableOption "configure Claude Code with metis skills, agents, and commands";
          options.metis.codex.enable = lib.mkEnableOption "configure Codex with metis skills, agents, and commands";

          config = lib.mkMerge [
            (lib.mkIf cfg.opencode.enable {
              home.file = {
                ".config/opencode/AGENTS.md".source = "${rendered}/context.md";
                ".config/opencode/agents".source = "${rendered}/agents";
                ".config/opencode/commands".source = "${rendered}/commands";
                ".config/opencode/skills".source = "${rendered}/skills";
                ".config/opencode/plugins".source = "${rendered}/plugins";
              };
            })
            (lib.mkIf cfg.claude.enable {
              home.file = {
                ".claude/CLAUDE.md".source = "${rendered}/context.md";
                ".claude/agents".source = "${rendered}/agents";
                ".claude/commands".source = "${rendered}/commands";
                ".claude/skills".source = "${rendered}/skills";
              };
            })
            (lib.mkIf cfg.codex.enable {
              home.file = {
                ".codex/AGENTS.md".source = "${rendered}/context.md";
                ".codex/agents".source = "${rendered}/agents";
                ".codex/commands".source = "${rendered}/commands";
                ".codex/skills".source = "${rendered}/skills";
              };
            })
          ];
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

            formatter = pkgs.nixfmt;
          }
        );
}
