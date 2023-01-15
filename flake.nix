{
  description = "Source code for lafreniere.xyz";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
    flake-utils.url = github:numtide/flake-utils;
    pre-commit-hooks = {
      url = github:cachix/pre-commit-hooks.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        buildInputs = with pkgs; [
          awscli2
          terraform
          terragrunt
        ];
      in
      rec {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              prettier.enable = true;
              typos.enable = true;
            };
          };
        };
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = buildInputs ++ (with pkgs; [
            nixfmt
            nodePackages_latest.prettier
            typos
          ]);
        };
      }
    );
}
