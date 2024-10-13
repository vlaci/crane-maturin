{
  lib,
  cmLib,
  maturin, # used to get example crate to test
}:

let
  src = "${maturin.src}/test-crates/pyo3-pure";
in
cmLib.buildMaturinPackage {
  pname = "pyo3-pure-test-src";
  inherit src;
  testSrc = lib.cleanSourceWith {
    src = cmLib.path src;
    filter =
      p: t:
      (cmLib.filterCargoSources p t)
      || (builtins.match ".*/(pyproject\.toml|tests|tests/.*\.py)$" p) != null;
  };
}
