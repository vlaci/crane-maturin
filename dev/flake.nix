# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    get-flake.url = "github:ursi/get-flake";
    crane.url = "github:ipetkov/crane";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      crane,
      get-flake,
      git-hooks,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      pre-commit-check = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        git-hooks.lib.${system}.run {
          src = ../.;
          package = pkgs.prek;
          hooks = {
            check-added-large-files.enable = true;
            end-of-file-fixer.enable = true;
            nixfmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            reuse.enable = true;
          };
        }
      );
    in
    {
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          inherit (pkgs) lib newScope runCommand;
          inherit crane get-flake;

          crane-maturin-src =
            runCommand "crane-maturin-src"
              {
                src = builtins.path {
                  path = ../.;
                  name = "source";
                  filter = path: _type: lib.hasSuffix ".nix" path;
                };
              }
              ''
                mkdir -p $out
                cp -r $src/* $out
                cp ${./flake.lock} $out/flake.lock
              '';

          crane-maturin = get-flake (toString crane-maturin-src);

          callPackage = newScope (pkgs // { inherit callPackage crane crane-maturin; });
        in
        lib.filterAttrs (_n: v: lib.isDerivation v) (callPackage ../tests { })
      );

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          inherit (pre-commit-check.${system}) shellHook;
        };
      });

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          inherit (pre-commit-check.${system}.config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );
    };
}
