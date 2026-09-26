# SPDX-FileCopyrightText: 2024 László Vaskó <vlaci@fastmail.com>
#
# SPDX-License-Identifier: MIT

{
  lib,
  path,
  craneLib,
  makeRustPlatform,
  callPackage,
  stdenv,
  python3,
  libiconv,
  maturin,
  cargo,
  rustc,
  cargo-llvm-cov,
  zstd,
  rsync,
  rust,
  llvm,
}:
args:

let
  inherit (lib)
    filterAttrs
    isDerivation
    optional
    optionalAttrs
    optionalString
    ;
  drv = lib.makeOverridable (
    args@{
      pname ? null,
      version ? null,
      src,
      testSrc ? src,
      buildInputs ? [ ],
      nativeBuildInputs ? [ ],
      pytestCheckInputs ? [ ],
      coverage ? false,
      python ? python3,
      advisory-db ? null,
      ...
    }:
    python.pkgs.buildPythonPackage (
      let
        pyprojectToml = builtins.fromTOML (builtins.readFile (src + "/pyproject.toml"));
        project = pyprojectToml.project or { };

        commonArgs = {
          inherit src nativeBuildInputs;

          doNotLinkInheritedArtifacts = true;
          installCargoArtifactsMode = "use-zstd";
          env.PYO3_PYTHON = "${python}/bin/python";

          buildInputs = [ python ] ++ lib.optionals stdenv.isDarwin [ libiconv ] ++ buildInputs;
        }
        // optionalAttrs (pname != null) {
          inherit pname;
        };

        cargoVendorDir = craneLib.vendorCargoDeps { inherit src; };

        cargoMaturinArtifacts = craneLib.buildDepsOnly (
          (builtins.removeAttrs commonArgs [ "src" ])
          // {
            pnameSuffix = "maturin-deps";
            dummySrc = craneLib.mkDummySrc {
              inherit src;
              extraDummyScript =
                let
                  cleanedPyprojectToml = {
                    inherit (pyprojectToml) build-system;
                    tool.maturin = pyprojectToml.tool.maturin // {
                      python-source = "missing/but/its/okay";
                    };
                  };
                in
                ''
                  cp ${craneLib.writeTOML "pyproject.toml" cleanedPyprojectToml} $out/pyproject.toml
                  mkdir -p $out/missing/but/its/okay
                '';
            };

            buildPhaseCargoCommand = ''
              ${rust.envVars.setEnv} maturin build --manylinux off --release
              rm -rf target/wheels
            '';
            doCheck = false;
            cargoToml = src + "/Cargo.toml";
            inherit cargoVendorDir;
            nativeBuildInputs = [
              maturin
              python
              rustc
            ];
          }
        );

        cargoArtifacts =
          (craneLib.buildDepsOnly (commonArgs // { inherit cargoVendorDir; })).overrideAttrs
            (_: {
              cargoArtifacts = cargoMaturinArtifacts;
            });

        crate = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });

        rustPlatform = makeRustPlatform { inherit cargo rustc; };

      in
      lib.recursiveUpdate
        (
          commonArgs
          // (builtins.removeAttrs args [
            "cargo"
            "rustc"
            "coverage"
            "pytestCheckInputs"
          ])
        )
        {
          version =
            if version != null then
              version
            else if project ? version && !(builtins.elem "version" (project.dynamic or [ ])) then
              project.version
            else
              crate.version;
          pname = (if pname != null then pname else crate.pname) + (optionalString coverage "-coverage");

          inherit cargoVendorDir;
          cargoArtifacts = cargoMaturinArtifacts;
          pyproject = true;

          # pname may be overridden or "-coverage" suffixed,
          # so it need not match the wheel's .dist-info
          dontCheckPythonMetadata = args.dontCheckPythonMetadata or true;

          strictDeps = true;

          preConfigure =
            optionalString coverage ''
              source <(cargo llvm-cov show-env --export-prefix)
            ''
            + (args.preConfigure or "");

          env = optionalAttrs coverage {
            LLVM_COV = "${llvm}/bin/llvm-cov";
            LLVM_PROFDATA = "${llvm}/bin/llvm-profdata";
          };

          nativeBuildInputs =
            let
              rustHooks = callPackage "${path}/pkgs/build-support/rust/hooks" { };
              pkgsHostTarget = {
                inherit maturin cargo rustc;
              };
            in
            with rustPlatform;
            with craneLib;
            [
              cargo
              cargoHelperFunctionsHook
              configureCargoCommonVarsHook
              configureCargoVendoredDepsHook
              inheritCargoArtifactsHook
              installCargoArtifactsHook
              replaceCargoLockHook
              rsync
              zstd
              (
                if rustHooks.maturinBuildHook ? override then
                  rustHooks.maturinBuildHook.override {
                    inherit pkgsHostTarget;
                  }
                else
                  (rustHooks.override { inherit pkgsHostTarget; }).maturinBuildHook
              )
            ]
            ++ nativeBuildInputs
            ++ optional coverage cargo-llvm-cov;

          passthru = {
            inherit crate;
            tests = filterAttrs (_n: isDerivation) (
              callPackage ./crane-maturin-tests.nix {
                inherit
                  craneLib
                  commonArgs
                  cargoArtifacts
                  drv
                  cargo
                  testSrc
                  python
                  advisory-db
                  pytestCheckInputs
                  ;
              }
            );
            withCoverage = drv.override { coverage = true; };
          };
        }
    )
  ) args;
in
drv
