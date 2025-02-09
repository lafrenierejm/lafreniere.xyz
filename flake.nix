{
  description = "Source code for lafreniere.xyz";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with inputs; [
        flake-root.flakeModule
        git-hooks.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # Pre-commit hooks.
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            alejandra.enable = true;
            prettier = {
              enable = true;
              files = "\\.(md|html|js|json)$";
            };
            terraform-format.enable = true;
            typos = {
              enable = true;
              types = ["text"];
            };
          };
        };

        # `nix develop`
        devShells.default = pkgs.mkShell {
          inputsFrom = [config.pre-commit.devShell];
          packages = with pkgs; [
            awscli2
            dig
            git-crypt
            hugo
            (opentofu.withPlugins (p: [p.aws]))
            python3
          ];
        };
      };
    };
}
