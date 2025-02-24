# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  lib,
  craneLib,
  system,
  cargo,
  drv,
  commonArgs,
  cargoArtifacts,
  testSrc,
  python,
  cargo-llvm-cov,
  advisory-db,
}:

let
  inherit (python.pkgs) buildPythonPackage pytestCheckHook;

  mkPytest =
    { nameSuffix, ... }@args:
    buildPythonPackage (
      {
        inherit (drv) version;
        pname = "${drv.pname}-test-${nameSuffix}";
        format = "other";

        src = testSrc;

        dontBuild = true;
        dontInstall = true;
      }
      // (builtins.removeAttrs args [ "nameSuffix" ])
    );
in
{
  pytest = mkPytest {
    nameSuffix = "pytest";
    nativeCheckInputs = [
      drv
      pytestCheckHook
    ];
  };

  clippy = craneLib.cargoClippy (
    commonArgs
    // {
      inherit cargoArtifacts;
      cargoClippyExtraArgs = "--all-targets -- --deny warnings";
    }
  );

  doc = craneLib.cargoDoc (commonArgs // { inherit cargoArtifacts; });

  test =
    let
      testCommand = if system == "aarch64-linux" then craneLib.cargoTest else craneLib.cargoNextest;
    in
    testCommand (
      commonArgs
      // {
        inherit cargoArtifacts;
      }
    );

  fmt = craneLib.cargoFmt commonArgs;

}
// lib.optionalAttrs (advisory-db != null) {
  audit = craneLib.cargoAudit (
    commonArgs
    // {
      inherit advisory-db;
    }
  );
}
// lib.optionalAttrs (system == "x86_64-linux") {
  test-coverage =
    (craneLib.cargoNextest (
      commonArgs
      // {
        inherit cargoArtifacts;
        env = {
          inherit (cargo-llvm-cov) LLVM_COV LLVM_PROFDATA;
        };
        cargoLlvmCovExtraArgs = "--ignore-filename-regex /nix/store --codecov --output-path $out/coverage.codecov";
        withLlvmCov = true;
      }
    )).overrideAttrs
      (super: {
        pname = "${super.pname}-coverage";
      });

  pytest-coverage = mkPytest {
    nameSuffix = "pytest-coverage";

    nativeCheckInputs = [
      drv.withCoverage
      cargo
      cargo-llvm-cov
      pytestCheckHook
    ];

    env = {
      inherit (cargo-llvm-cov) LLVM_COV LLVM_PROFDATA;
    };

    preCheck = ''
      source <(cargo llvm-cov show-env --export-prefix)
      LLVM_COV_FLAGS=$(echo -n $(find ${drv.withCoverage} -name "*.so"))
      export LLVM_COV_FLAGS
    '';

    postCheck = ''
      mkdir -p $out
      cargo llvm-cov report --ignore-filename-regex "(/nix/store|/std/src|rustc-.*-src)" --summary-only
      cargo llvm-cov report --ignore-filename-regex "(/nix/store|/std/src|rustc-.*-src)" --codecov --output-path $out/coverage.codecov
    '';
  };
}
