{
  description = "LLM skills, commands, and agents packaged as a home-manager consumable Nix flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    # obra/superpowers: A complete software development workflow for coding agents.
    # https://github.com/obra/superpowers
    superpowers = {
      url = "github:obra/superpowers/v4.3.1";
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

      mkSettings =
        {
          pkgs,
          mattPocockSkillsSource ? sources.matt-pocock-skills,
        }:
        import ./default.nix {
          inherit pkgs sources mattPocockSkillsSource;
          basePath = self;
        };
    in
    {
      lib.mkSettings = mkSettings;
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
            settings = mkSettings { inherit pkgs; };
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
