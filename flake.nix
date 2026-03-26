# SPDX-FileCopyrightText: 2024-2026 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  outputs = _: {
    mkLib =
      crane: pkgs:
      let
        craneLib = crane.mkLib pkgs;
      in
      craneLib.overrideScope (
        final: _prev: {
          buildMaturinPackage = pkgs.callPackage ./buildMaturinPythonPackage.nix { craneLib = final; };
        }
      );
  };
}
