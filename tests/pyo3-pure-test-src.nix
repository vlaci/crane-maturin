# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  lib,
  cmLib,
  test-crates,
}:

let
  src = "${test-crates}/pyo3-pure";
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
