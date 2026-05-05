{
  description = "Source code for lafreniere.xyz";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with inputs; [
        git-hooks.flakeModule
        treefmt-nix.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        tofu = pkgs.opentofu.withPlugins (p: [p.hashicorp_aws]);
      in {
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            prettier = {
              enable = true;
              includes = ["*.md" "*.html" "*.js" "*.json" "*.tfstate"];
            };
            ruff.enable = true;
            ruff-format.enable = true;
            terraform = {
              enable = true;
              package = tofu;
            };
          };
        };

        # Pre-commit hooks.
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
            };
            typos = {
              enable = true;
              types = ["text"];
              excludes = ["terraform.tfstate"];
            };
          };
        };

        # `nix develop`
        devShells.default = pkgs.mkShell {
          inputsFrom = [config.pre-commit.devShell config.treefmt.build.devShell];
          packages = pkgs.lib.lists.flatten [
            tofu
            (with pkgs; [
              awscli2
              dig
              git-crypt
              hugo
              python3
            ])
          ];
        };
      };
    };
}
