{
  crane,
  crane-maturin,
  pkgs,
  lib,
  newScope,
}:

let
  cmLib = crane-maturin.mkLib crane pkgs;
  callPackage = newScope (pkgs // { inherit cmLib; });
  checks = {
    pyo3-pure = callPackage ./pyo3-pure.nix { };
    pyo3-pure-custom-python = callPackage ./pyo3-pure-custom-python.nix { };
    pyo3-pure-test-src = callPackage ./pyo3-pure-test-src.nix { };
  };
in
lib.concatMapAttrs (
  name: value: lib.mapAttrs' (n: v: lib.nameValuePair "${name}-${n}" v) value.passthru.tests
) checks
