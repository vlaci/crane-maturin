# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{ inputs, ... }:

{
  systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      pre-commit = {
        settings.hooks = {
          treefmt = {
            enable = true;
            always_run = true;
          };
          reuse = {
            enable = true;
            name = "reuse";
            description = "Run REUSE compliance tests";
            entry = "${pkgs.reuse}/bin/reuse lint";
            pass_filenames = false;
            always_run = true;
          };
        };
      };
      treefmt.config = {
        projectRootFile = "flake.nix";
        programs = {
          statix.enable = true;
          deadnix.enable = true;
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
        };
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ maturin ];
        inputsFrom = [
          config.pre-commit.devShell
          config.treefmt.build.devShell
        ];
      };

      checks =
        let
          inherit (pkgs) lib newScope runCommand;
          inherit (inputs) crane get-flake;

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
        lib.filterAttrs (_n: v: lib.isDerivation v) (callPackage ../tests { });

    };
}
