# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  crane,
  crane-maturin,
  pkgs,
  lib,
  newScope,
}:

let
  cmLib = crane-maturin.mkLib crane pkgs;
  test-crates = pkgs.runCommandNoCC "test-crates" { inherit (pkgs.maturin) src; } ''
    mkdir -p $out
    cp -r $src/test-crates/pyo3-pure $out

    for rs in $out/*/src/lib.rs; do
      chmod u+w $rs
      echo $rs
      cat <<EOF >> $rs

    #[cfg(test)]
    mod tests {
        #[test]
        fn test_dummy() {}
    }
    EOF
    done
  '';
  callPackage = newScope (pkgs // { inherit cmLib test-crates; });
  checks = {
    pyo3-pure = callPackage ./pyo3-pure.nix { };
    pyo3-pure-custom-python = callPackage ./pyo3-pure-custom-python.nix { };
    pyo3-pure-test-src = callPackage ./pyo3-pure-test-src.nix { };
  };
in
lib.concatMapAttrs (
  name: value: lib.mapAttrs' (n: v: lib.nameValuePair "${name}-${n}" v) value.passthru.tests
) checks
