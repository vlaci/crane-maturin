{
  lib,
  pkgs,
  crane-maturin,
  crane,
  system,
  maturin, # used to get example crate to test
}:

let
  src = "${maturin.src}/test-crates/pyo3-pure";
  craneLib = crane.mkLib pkgs;
in
crane-maturin.lib.${system}.buildMaturinPythonPackage {
  pname = "pyo3-pure-test-src";
  inherit src;
  testSrc = lib.cleanSourceWith {
    src = craneLib.path src;
    filter =
      p: t:
      (craneLib.filterCargoSources p t)
      || (builtins.match ".*/(pyproject\.toml|tests|tests/.*\.py)$" p) != null;
  };
}
