# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ ];
      imports = [ flake-parts.flakeModules.partitions ];
      partitionedAttrs.checks = "dev";
      partitionedAttrs.devShells = "dev";
      partitions.dev.extraInputsFlake = ./dev;
      partitions.dev.module = {
        imports = [ ./dev/flake-module.nix ];
      };
      flake = {
        mkLib =
          crane: pkgs:
          let
            craneLib = crane.mkLib pkgs;
          in
          {
            buildMaturinPackage = pkgs.callPackage ./buildMaturinPythonPackage.nix { inherit craneLib; };
          }
          // craneLib;
      };
    };
}
